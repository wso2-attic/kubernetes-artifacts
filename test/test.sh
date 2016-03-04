#!/bin/bash
# ------------------------------------------------------------------------
#
# Copyright 2005-2015 WSO2, Inc. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

# ------------------------------------------------------------------------

########################### Simple Test Script ############################
# 
#   This script will build the default version of specified docker images, 
#   scp them to the Kubernetes nodes and deploy the Kubernetes artifacts.
#
#   Tested with the Kubernetes setup at:
#   https://github.com/pires/kubernetes-vagrant-coreos-cluster
#
#   Usage: 
#   1. set PUPPET_HOME in environment.bash
#   2. add the products and version that need to be tested to the array 
#      'products' as comma separated tuples.
#       ex.: products=(wso2am,1.9.1 wso2is,5.0.0)
#   3. run the script
#
#
###########################################################################

set -e

kubernetes_artifact_version=1.0.0
node_scp_address=core@172.17.8.102
default_profile=default
source environment.bash
source ~/.bash_profile

# build common image
prgdir=`dirname "$0"`
current_path=`cd "$prgdir"; pwd`
root_dir=${current_path}/..
common_dir=${current_path}/../common
base_image_dir=`cd "${common_dir}/docker/base-image"; pwd`

user=`whoami`
echo "user executing the script $user"

function build_base_image {
    # navigate to base image dir
    pushd $base_image_dir
    # build
    # sudo bash build.sh ${kubernetes_artifact_version}
    # go back to previous directory location
    popd
}

function build_docker_image_and_scp {
    # switch to IS 5 docker directory and build
    pushd ${root_dir}/$1/docker
    echo pwd=`pwd`
    sudo --preserve-env bash build.sh $2 ${kubernetes_artifact_version} $3
    # save the image as a tar file
    sudo bash save.sh $2 ${kubernetes_artifact_version} $3
    sudo chown $user:$user -R ~/docker/ 
    bash scp.sh ${node_scp_address} $2 ${kubernetes_artifact_version} $3
    popd
}

#function deploy_kubernetes_artifacts {
#    # switch to IS 5 kubernetes directory deploy kubernetes artifacts
#    pushd ${root_dir}/$1/kubernetes
#    bash deploy.sh
#    popd
#}

function undeploy_kubernetes_artifacts {
    # switch to IS 5 kubernetes directory deploy kubernetes artifacts
    pushd ${root_dir}/$1/kubernetes
    bash undeploy.sh
    popd
}

function deploy_kubernetes_artifacts {
    # switch to IS 5 kubernetes directory deploy kubernetes artifacts
    pushd ${root_dir}/$1/kubernetes
    echo "Deploying $1 $2 service..."
    kubectl create -f "$1"-"$2"-service.yaml
    echo "Deploying $1 $2 controller..."
    kubectl create -f "$1"-"$2"-controller.yaml
    popd
}


function check_status {
    error_count=0
    success_count=0
    while true; do
        # check the pod status
        result=`kubectl get pods | grep $1`
        if [[ -z $result ]]; then
           echo "no pod found for product $1"
           error_count=$((error_count + 1))
           success_count=0
        fi
        IFS=' ' read -r -a array <<< "$result"
        pod_name=${array[0]}
        ready=${array[1]}
        state=${array[2]}
        restarts=${array[3]}
        if [[ $ready != '1/1' ]] || [[ $state != 'Running' ]] || [[ $restarts != '0'  ]]; then
            echo "error condition detected in pod $pod_name":
            echo "pod name=$pod_name, ready=$ready, status=$state, restarts=$restarts"
            error_count=$((error_count + 1))
            success_count=0
        else
            success_count=$((success_count + 1))
            error_count=0
        fi

        if [[ $error_count -gt 5 ]]; then
            echo "error condition threshold reached: $error_count, exiting"
	        undeploy_kubernetes_artifacts "$1"
            exit
        elif [[ $success_count -gt 5 ]]; then
            echo "success condition threshold reached: $success_count"
            server_started=$(check_carbon_server_has_started "$pod_name")
            if [[ $server_started -eq 0 ]]; then
                echo "Carbon Server in pod $pod_name has started successfully"
                break
            else
                echo "Carbon Server in pod $pod_name has failed to start"
                undeploy_kubernetes_artifacts "$1"
                exit
            fi
        fi
        sleep 6s
    done
}

function check_carbon_server_has_started {
    carbon_logs=`kubectl logs $1`
    tries=0
    while [[ tries < 10 ]]; do
        if [[ $carbon_logs == *"Mgt Console URL"* ]]; then
            echo 0;
        else
            tries=$((tries + 1))
            if [[ tries -gt 10 ]]; then
                break
            fi
        fi
        sleep 6s
    done
    echo 1
}

# build the base images
build_base_image
# build and deploy the products
products=(wso2am,1.9.1)

for product in ${products[@]}; do
    IFS=","
    set $product
    echo "############################### testing $1 v.$2 ###############################"
    echo 'building docker image for='$1 ' version='$2
    build_docker_image_and_scp "$1" "$2" "${default_profile}"
    echo 'deploying kubernetes artifacts for='$1 ' version='$2
    deploy_kubernetes_artifacts "$1" "${default_profile}"
    check_status "$1"
    echo 'undeploying kubernetes artifacts for='$1 ' version='$2
    undeploy_kubernetes_artifacts "$1"
    echo "########################## completed testing $1 v.$2 ##########################"
    unset IFS
done

