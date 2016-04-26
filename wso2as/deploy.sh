#!/bin/bash
# ------------------------------------------------------------------------
#
# Copyright 2016 WSO2, Inc. (http://wso2.com)
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

manager_port=32021
worker_port=32023
default_port=32023

prgdir=$(dirname "$0")
script_path=$(cd "$prgdir"; pwd)
common_scripts_folder=$(cd "${script_path}/../common/scripts/"; pwd)
source "${common_scripts_folder}/base.sh"

# deploy DB service and rc
echo "Deploying AS database Service..."
kubectl create -f "mysql-asdb-service.yaml"

echo "Deploying AS database Replication Controller..."
kubectl create -f "mysql-asdb-controller.yaml"

# wait till mysql is started
# TODO: find a better way to do this
sleep 10

# Deploy using separate profiles
function distributed {
    # deploy services
    bash "${common_scripts_folder}/deploy-kubernetes-service.sh" "manager" && \
    bash "${common_scripts_folder}/deploy-kubernetes-service.sh" "worker" && \

    # deploy the controllers
    bash "${common_scripts_folder}/deploy-kubernetes-rc.sh" "manager" && \
    bash "${common_scripts_folder}/wait-until-server-starts.sh" "manager" "${manager_port}" && \

    bash "${common_scripts_folder}/deploy-kubernetes-rc.sh" "worker" && \
    bash "${common_scripts_folder}/wait-until-server-starts.sh" "worker" "${worker_port}"
}

while getopts :dh FLAG; do
    case $FLAG in
        d)
            deployment_pattern="distributed"
            ;;
        h)
            showUsageAndExitDistributed
            ;;
        \?)
            default "${default_port}"
            ;;
    esac
done

validateKubeCtlConfig
if [ "$deployment_pattern" = "distributed" ]; then
    distributed
else
    default "${default_port}"
fi
