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

default_port=32061

prgdir=$(dirname "$0")
script_path=$(cd "$prgdir"; pwd)
common_scripts_folder=$(cd "${script_path}/../common/scripts/"; pwd)
source "${common_scripts_folder}/base.sh"

while getopts :h FLAG; do
    case $FLAG in
        h)
            showUsageAndExitDefault
            ;;
        \?)
            showUsageAndExitDefault
            ;;
    esac
done

validateKubeCtlConfig

bash $script_path/../common/wso2-shared-dbs/deploy.sh

# deploy DB service and rc
echo "Deploying DAS database Service..."
kubectl create -f "mysql-dasdb-service.yaml"

echo "Deploying DAS database Replication Controller..."
kubectl create -f "mysql-dasdb-controller.yaml"

# wait till mysql is started
# TODO: find a better way to do this
sleep 10

default "${default_port}"
