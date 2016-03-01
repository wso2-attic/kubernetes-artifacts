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


# navigate to base image dir
pushd $base_image_dir
# build
  sudo bash build.sh ${kubernetes_artifact_version} 
# go back to previous directory location
popd

function build_docker_image_and_scp {
    # switch to IS 5 docker directory and build
    pushd ${root_dir}/$1/docker
    echo pwd=`pwd`
    sudo --preserve-env bash build.sh $2 ${kubernetes_artifact_version} ${default_profile}
    # save the image as a tar file
    sudo bash save.sh $2 ${kubernetes_artifact_version} ${default_profile}
    sudo chown $user:$user -R ~/docker/ 
    bash scp.sh ${node_scp_address} $2 ${kubernetes_artifact_version} ${default_profile}
    popd
}

function deploy_kubernetes_artifacts {
    # switch to IS 5 kubernetes directory deploy kubernetes artifacts
    pushd ${root_dir}/$1/kubernetes
    bash deploy.sh    
    popd
}

function undeploy_kubernetes_artifacts {
    # switch to IS 5 kubernetes directory deploy kubernetes artifacts
    pushd ${root_dir}/$1/kubernetes
    bash undeploy.sh
    popd
}


# build and deploy
build_docker_image_and_scp 'wso2is' '5.0.0'
deploy_kubernetes_artifacts 'wso2is'
