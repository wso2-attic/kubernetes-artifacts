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

########################### Simple Test Script ##############################
#                                                                           #
#   This script will build the default version of specified docker images,  #
#   scp them to the Kubernetes nodes and deploy the Kubernetes artifacts.   #
#                                                                           #
#   Tested with the Kubernetes setup at:                                    #
#   https://github.com/pires/kubernetes-vagrant-coreos-cluster              #
#                                                                           #
#   Usage:                                                                  #
#   1. set PUPPET_HOME, KUBERNETES_NODE_USER and KUBERNETES_NODE            #
#      in environment.bash                                                  #
#   2. add the products and version that need to be tested to the array     #
#      'products' as comma separated tuples.                                #
#       ex.: products=(wso2am,1.9.1 wso2is,5.0.0)                           #
#   3. run the script                                                       #
#                                                                           #
#                                                                           #
#############################################################################

set -e

kubernetes_artifact_version=1.0.0
source environment.bash
source ~/.bash_profile

prgdir=`dirname "$0"`
current_path=`cd "$prgdir"; pwd`
root_dir=${current_path}/..
common_dir=${current_path}/../common
base_image_dir=`cd "${common_dir}/docker/base-image"; pwd`

user=`whoami`
echo "user executing the script $user"

# products to be tested
products=(wso2dss,3.5.0,manager)
declare -A results

function echoError {
    echo $'\e[1;31m'"${1}"$'\e[0m'
}

function echoSuccess {
    echo $'\e[1;32m'"${1}"$'\e[0m'
}

function echoBold {
    echo $'\e[1m'"${1}"$'\e[0m'
}

# build base image
function build_base_image {
    # navigate to base image dir
    pushd ${base_image_dir} > /dev/null
    # build
    # sudo bash build.sh ${kubernetes_artifact_version}
    # go back to previous directory location
    popd > /dev/null
}

function build_docker_image_and_scp {
    # switch to IS 5 docker directory and build
    pushd ${root_dir}/$1/docker > /dev/null
    sudo --preserve-env bash build.sh "$2" ${kubernetes_artifact_version} "$3" || cleanup
    # save the image as a tar file
    sudo bash save.sh "$2" ${kubernetes_artifact_version} "$3" || cleanup
    sudo chown ${user}:${user} -R ~/docker/
    bash scp.sh ${KUBERNETES_NODE_USER}@${KUBERNETES_NODE} "$2" ${kubernetes_artifact_version} "$3" || cleanup
    popd > /dev/null
}

function undeploy_kubernetes_artifacts {
    # switch to IS 5 kubernetes directory deploy kubernetes artifacts
    pushd ${root_dir}/$1/kubernetes > /dev/null
    bash undeploy.sh
    popd > /dev/null
}

function deploy_kubernetes_service {
    # switch to IS 5 kubernetes directory deploy kubernetes artifacts
    echo "Deploying $1 $2 service..."
    bash ${common_dir}/scripts/kubernetes/deploy-kubernetes-service.sh "$1" "$2" || cleanup
}

function deploy_kubernetes_rc {
    # switch to IS 5 kubernetes directory deploy kubernetes artifacts
    echo "Deploying $1 $2 controller..."
    bash ${common_dir}/scripts/kubernetes/deploy-kubernetes-rc.sh "$1" "$2" || cleanup
}


function check_status {
    error_count=0
    success_count=0
    while true; do
        # check the pod status
        result=`kubectl get pods | grep $1-$3`
        if [[ -z "$result" ]]; then
           echo "no pod found for product $1"
           error_count=$((error_count + 1))
           success_count=0
        fi
        IFS=' ' read -r -a array <<< "$result"
        pod_name=${array[0]}
        ready=${array[1]}
        state=${array[2]}
        restarts=${array[3]}
        if [[ ${ready} != '1/1' ]] || [[ $state != 'Running' ]] || [[ $restarts != '0'  ]]; then
            echo "error condition detected in pod=$pod_name, ready=$ready, status=$state, restarts=$restarts"
            error_count=$((error_count + 1))
            success_count=0
        else
            success_count=$((success_count + 1))
            error_count=0
        fi

        if [[ ${error_count} -gt 5 ]]; then
            echo "error condition threshold reached: $error_count, aborting"
	        #undeploy_kubernetes_artifacts "$1"
            results[$1-$2]="ERROR, last pod name=$pod_name, state=$state, restarts=$restarts"
            break
        elif [[ ${success_count} -gt 5 ]]; then
            echo "success condition threshold reached: $success_count"
            server_started=$(check_carbon_server_has_started "$pod_name")
            if [[ ${server_started} -eq 0 ]]; then
                msg="Carbon Server $1-$2 in pod $pod_name has started successfully"
                echo ${msg}
                results[$1-$2]="SUCCESS, $msg"
                break
            else
                msg="Carbon Server $1-$2 in pod $pod_name has failed to start"
                echo ${msg}
                #undeploy_kubernetes_artifacts "$1"
                results[$1-$2]="ERROR, $msg"
                break
            fi
        else
            sleep 6s
        fi
    done
}

function check_carbon_server_has_started {
    tries=0
    while true; do
        carbon_logs=`kubectl logs $1`
        if [[ ${carbon_logs} =~ "Mgt Console URL" ]]; then
            echo 0
            break
        else
            tries=$((tries + 1))
            # allow the Carbon server to start for 5 minutes (6s * 50 = 5 mins)
            if [[ ${tries} -gt 50 ]]; then
                echo 1
                break
            fi
        fi
        sleep 6s
    done
}

function validate_environment {
    if [ -z "$PUPPET_HOME" ]; then
        echo "please set environment variable PUPPET_HOME"
        exit
    fi
    if [ -z "$KUBERNETES_NODE" ]; then
        echo "please set environment variable KUBERNETES_NODE"
        exit
    fi
    if [ -z "$KUBERNETES_NODE_USER" ]; then
        echo "please set environment variable KUBERNETES_NODE_USER"
        exit
    fi
}

function test {
    # build and scp
#    for product in ${products[@]}; do
#        IFS=","
#        set ${product}
#        echo "building docker image for=$1  version=$2 profile=$3"
#        build_docker_image_and_scp "$1" "$2" "$3"
#        unset IFS
#    done
#    # deploy all Services
#    for product in ${products[@]}; do
#        IFS=","
#        set ${product}
#        echo "deploying kubernetes Service for=$1 version=$2 profile=$3"
#        deploy_kubernetes_service "$1" "$3"
#        unset IFS
#    done
#    # deploy RCs and check status
    for product in ${products[@]}; do
        IFS=","
        set ${product}
        echo "deploying kubernetes RC for=$1 version=$2 profile=$3"
        deploy_kubernetes_rc "$1" "$3"
        check_status "$1" "$2" "$3"
        echo "undeploying kubernetes artifacts for=$1 version=$2 profile=$3"
        undeploy_kubernetes_artifacts "$1"
        unset IFS
    done
}

function print_results {
    unset IFS
    echoBold "################################################# Results #################################################"
    for product in ${products[@]}; do
        IFS=","
        set ${product}
        test_result=${results[$1-$2]}
        if [[ ${test_result} == ERROR* ]]; then
            echoError "$1-$2: ${test_result}"
        else
            echoSuccess "$1-$2: ${test_result}"
        fi
        unset IFS
    done
    echoBold "############################################## End of Results #############################################"
}

function cleanup {
    unset IFS
    for product in ${products[@]}; do
        IFS=","
        set ${product}
        echo "Cleaning up for=$1 version=$2 profile=$3"
        undeploy_kubernetes_artifacts "$1"
        unset IFS
    done
}

# validate
validate_environment
# build the base images
build_base_image
# build and deploy the products
test
# print results
print_results
