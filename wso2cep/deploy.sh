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

presenter_port=32051
worker_port=32053
default_port=32053

prgdir=$(dirname "$0")
script_path=$(cd "$prgdir"; pwd)
common_scripts_folder=$(cd "${script_path}/../common/scripts/"; pwd)
source "${common_scripts_folder}/base.sh"

# Deploy using separate profiles
function distributed {
    # deploy services
    bash "${common_scripts_folder}/deploy-kubernetes-service.sh" "presenter" && \
    bash "${common_scripts_folder}/deploy-kubernetes-service.sh" "worker" && \

    # deploy the controllers
    bash "${common_scripts_folder}/deploy-kubernetes-rc.sh" "presenter" && \
    bash "${common_scripts_folder}/wait-until-server-starts.sh" "presenter" "${presenter_port}" && \

    bash "${common_scripts_folder}/deploy-kubernetes-rc.sh" "worker" && \
    bash "${common_scripts_folder}/wait-until-server-starts.sh" "worker" "${worker_port}"
}

full_deployment=false

while getopts :dh FLAG; do
    case $FLAG in
        d)
            deployment_pattern="distributed"
            ;;
        f)
            full_deployment=true
            ;;
        h)
            showUsageAndExitDistributed
            ;;
        \?)
            showUsageAndExitDistributed
            ;;
    esac
done

validateKubeCtlConfig

if [ $full_deployment == true ]; then
    echo "Deploying MySQL Services and RCs for Conf and Gov remote mounting..."
    bash $script_path/../common/wso2-shared-dbs/deploy.sh
fi

# deploy DB service and rc
echo "Deploying CEP database Service..."
kubectl create -f "mysql-cepdb-service.yaml"

echo "Deploying CEP database Replication Controller..."
kubectl create -f "mysql-cepdb-controller.yaml"

# wait till mysql is started
# TODO: find a better way to do this
sleep 10

if [ "$deployment_pattern" = "distributed" ]; then
    distributed
else
    default "${default_port}"
fi
