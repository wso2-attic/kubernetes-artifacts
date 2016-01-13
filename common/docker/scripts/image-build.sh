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

if [ -z "$2" ]
  then
    echo "Usage: ./build.sh [docker-image-version]"
    exit
fi

image_version=$2
image_id=wso2/$3:${image_version}
dockerfile_path=$1

echo "Building docker image ${image_id}..."

prgdir2=`dirname "$0"`
self_path=`cd "$prgdir2"; pwd`

cp $self_path/docker-init.sh $dockerfile_path/scripts/init.sh
cp -r $self_path/../../../puppet $dockerfile_path/

docker build -t ${image_id} $dockerfile_path

echo "Cleaning..."
rm -rf $dockerfile_path/scripts/init.sh
rm -rf $dockerfile_path/puppet
echo "Docker image ${image_id} created."