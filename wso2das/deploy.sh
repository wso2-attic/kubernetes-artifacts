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

default_port=32001

prgdir=$(dirname "$0")
script_path=$(cd "$prgdir"; pwd)
common_scripts_folder=$(cd "${script_path}/../common/scripts/"; pwd)

# Deploy using default profile
function default {
  bash "${common_scripts_folder}/deploy-kubernetes-service.sh" "wso2das" "default" && \
  bash "${common_scripts_folder}/deploy-kubernetes-rc.sh" "wso2das" "default" && \
  bash "${common_scripts_folder}/wait-until-server-starts.sh" "wso2das" "default" "${default_port}"
}

function showUsageAndExit () {
    echo "Usage: ./deploy.sh [OPTIONS]"
    echo
    echo "Deploy Replication Controllers and Services on Kubernetes"
    echo

    echo " -h  - Help"
    echo

    echo "Ex: ./deploy.sh -h"
    exit 1
}

while getopts :h FLAG; do
    case $FLAG in
        h)
            showUsageAndExit
            ;;
        \?)
            default
            ;;
    esac
done

default
