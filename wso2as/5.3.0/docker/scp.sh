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

product_name=as
product_version=5.3.0
product_profiles='default|manager|worker'
minions='core@ip1|core@ip2'
image_version=$1

if [ -z "$1" ]
  then
    echo "Usage: ./scp.sh [docker-image-version]"
    exit
fi

image_version=$1

prgdir=`dirname "$0"`
script_path=`cd "$prgdir"; pwd`
common_folder=`cd "${script_path}/../../../common/scripts/docker/"; pwd`

echo "Importing docker images to master and minion-1"
bash ${common_folder}/scp-cmd.sh ${product_name} ${product_version} ${image_version} ${product_version} ${minions}
pid1=$!

wait $pid1
echo "Docker images imported successfully!"
