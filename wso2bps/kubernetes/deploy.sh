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

host=172.17.8.102
manager_port=32001
worker_port=32003
default_port=32003

prgdir=`dirname "$0"`
script_path=`cd "$prgdir"; pwd`
common_scripts_folder=`cd "${script_path}/../../common/scripts/kubernetes/"; pwd`

echo "Deploying wso2bps manager service..."
kubectl create -f wso2bps-manager-service.yaml

echo "Deploying wso2bps worker service..."
kubectl create -f wso2bps-worker-service.yaml

echo "Deploying wso2bps manager controller..."
kubectl create -f wso2bps-manager-controller.yaml

echo "Waiting wso2bps manager to launch on http://${host}:${manager_port}"
until $(curl --output /dev/null --silent --head --fail http://${host}:${manager_port}); do
    printf '.'
    sleep 5
done

echo -e "\nwso2bps manager launched!"

echo "Deploying wso2bps worker controller..."
kubectl create -f wso2bps-worker-controller.yaml

echo "Waiting wso2bps worker to launch on http://${host}:${worker_port}"
until $(curl --output /dev/null --silent --head --fail http://${host}:${worker_port}); do
    printf '.'
    sleep 5
done

echo -e "\nwso2bps worker launched!"



# Deploy using default profile
function default {
  bash ${common_scripts_folder}/deploy-kubernetes-service.sh "wso2bps" "default"
  bash ${common_scripts_folder}/deploy-kubernetes-rc.sh "wso2bps" "default"
  bash ${common_scripts_folder}/wait-until-server-starts.sh "wso2bps" "default" "${host}" "${default_port}"
}

# Deploy using separate profiles
function distributed {

    # deploy services

    bash ${common_scripts_folder}/deploy-kubernetes-service.sh "wso2bps" "manager"
    bash ${common_scripts_folder}/deploy-kubernetes-service.sh "wso2bps" "worker"

    # deploy the controllers

    bash ${common_scripts_folder}/deploy-kubernetes-rc.sh "wso2bps" "manager"
    bash ${common_scripts_folder}/wait-until-server-starts.sh "wso2bps" "manager" "${host}" "${manager_port}"

    bash ${common_scripts_folder}/deploy-kubernetes-rc.sh "wso2bps" "worker"
    bash ${common_scripts_folder}/wait-until-server-starts.sh "wso2am" "worker" "${host}" "${worker_port}"
}

pattern=$1
if [ -z "$pattern" ]
  then
    pattern='default'
fi

if [ "$pattern" = "default" ]; then
  default
elif [ "$pattern" = "distributed" ]; then
  distributed
else
  echo "Usage: ./deploy.sh [default|distributed]"
  echo "ex: ./deploy.sh default"
  exit 1
fi