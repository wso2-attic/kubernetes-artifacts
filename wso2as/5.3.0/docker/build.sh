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

if [ -z "$1" ]
  then
    echo "Usage: ./build.sh [docker-image-version]"
    exit 1
fi

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

prgdir=`dirname "$0"`
script_path=`cd "$prgdir"; pwd`
common_folder=`cd "${script_path}/../../../common/docker/scripts/"; pwd`

echo "Creating Manager image..."
sed -i '/ENV WSO2_SERVER_PROFILE/c\ENV WSO2_SERVER_PROFILE manager' Dockerfile
bash ${common_folder}/image-build.sh ${script_path} $1 as-manager-5.3.0

echo "Creating Worker image..."
sed -i '/ENV WSO2_SERVER_PROFILE/c\ENV WSO2_SERVER_PROFILE worker' Dockerfile
bash ${common_folder}/image-build.sh ${script_path} $1 as-worker-5.3.0

echo "Creating Default image..."
sed -i '/ENV WSO2_SERVER_PROFILE/c\ENV WSO2_SERVER_PROFILE default' Dockerfile
bash ${common_folder}/image-build.sh ${script_path} $1 as-5.3.0