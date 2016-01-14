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
    echo "Usage: ./scp.sh [docker-image-version]"
    exit
fi

product_name=$1
product_version=$2
image_version=$3
profiles=$4
nodes=$5

IFS='|' read -r -a array <<< "${profiles}"
for profile in "${array[@]}"
do
    if [[ $profile = "default" ]]; then
        image_id="wso2/${product_name}-${product_version}:${image_version}"
        tar_file="wso2${product_name}-${product_version}-${image_version}.tar"
    else
        image_id="wso2/${product_name}-${profile}-${product_version}:${image_version}"
        tar_file="wso2${product_name}-${profile}-${product_version}-${image_version}.tar"
    fi

    IFS='|' read -r -a array2 <<< "${nodes}"
    for node in "${array2[@]}"
    do
        echo "scp ~/docker/images/${tar_file} ${node}:"
        scp ~/docker/images/${tar_file} ${node}:
        echo "ssh ${node} \"docker load < ${tar_file}\""
        ssh ${node} "docker load < ${tar_file}"
        echo "ssh ${node} \"rm ${tar_file}\""
        ssh ${node} "rm ${tar_file}"
    done
done
