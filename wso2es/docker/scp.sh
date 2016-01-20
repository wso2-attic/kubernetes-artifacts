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

image_version=$1
tar_file="imesh-wso2es-2.0.0-${image_version}.tar"

echo "Importing ${tar_file} to knode1"
./scp-cmd.sh ${tar_file} knode1 &
pid1=$!

echo "Importing ${tar_file} to knode2"
./scp-cmd.sh ${tar_file} knode2 &
pid2=$!

wait $pid1
wait $pid2
echo "${tar_file} imported successfully!"
