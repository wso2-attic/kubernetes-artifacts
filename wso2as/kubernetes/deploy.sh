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

prgdir=$(dirname "$0")
script_path=$(cd "$prgdir"; pwd)
common_scripts_folder=$(cd "${script_path}/../../common/scripts/kubernetes/"; pwd)

# Deploy using default profile
function default {
    bash "${common_scripts_folder}/deploy-kubernetes-service.sh" "wso2as" "default"
    bash "${common_scripts_folder}/deploy-kubernetes-rc.sh" "wso2as" "default"
    bash "${common_scripts_folder}/wait-until-server-starts.sh" "wso2as" "default" "${host}" "${default_port}"
}

# Deploy using separate profiles
function distributed {
    # deploy services
    bash "${common_scripts_folder}/deploy-kubernetes-service.sh" "wso2as" "manager"
    bash "${common_scripts_folder}/deploy-kubernetes-service.sh" "wso2as" "worker"

    # deploy the controllers
    bash "${common_scripts_folder}/deploy-kubernetes-rc.sh" "wso2as" "manager"
    bash "${common_scripts_folder}/wait-until-server-starts.sh" "wso2as" "manager" "${host}" "${manager_port}"

    bash "${common_scripts_folder}/deploy-kubernetes-rc.sh" "wso2as" "worker"
    bash "${common_scripts_folder}/wait-until-server-starts.sh" "wso2as" "worker" "${host}" "${worker_port}"
}

function showUsageAndExit () {
    echo "Usage: ./deploy.sh -d [default|distributed] [OPTIONAL] -h [host IP]"
    echo "ex: ./deploy.sh -d default"
    echo "ex: ./deploy.sh -d default -h 172.17.8.103"
    exit 1
}

while getopts :d:h: FLAG; do
    case $FLAG in
        d)
            deployment_pattern=$OPTARG
            ;;
        h)
            host=$OPTARG
            ;;
        \?)
            showUsageAndExit
            ;;
    esac
done

if [ "$deployment_pattern" = "default" ]; then
    default
elif [ "$deployment_pattern" = "distributed" ]; then
    distributed
else
    showUsageAndExit
fi
