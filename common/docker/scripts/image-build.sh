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

dockerfile_path=$1
image_version=$2
product_name=$3
product_version=$4
profiles=$5

prgdir2=`dirname "$0"`
self_path=`cd "$prgdir2"; pwd`

cp $self_path/docker-init.sh $dockerfile_path/scripts/init.sh
cp -r $self_path/../../../puppet $dockerfile_path/
cp $dockerfile_path/Dockerfile $dockerfile_path/Dockerfile.bck

IFS='|' read -r -a array <<< "${profiles}"
for element in "${array[@]}"
do
    echo "ELEMENT: $element"
    image_id="wso2/${product_name}-${element}-${product_version}:${image_version}"

    echo "Building docker image ${image_id}..."
    sed -i "/ENV WSO2_SERVER_PROFILE/c\ENV WSO2_SERVER_PROFILE ${element}" "${dockerfile_path}/Dockerfile"
    docker build -t ${image_id} $dockerfile_path

    echo "Docker image ${image_id} created."
done

echo "Cleaning..."
rm -rf $dockerfile_path/scripts/init.sh
rm -rf $dockerfile_path/puppet/hiera*
rm -rf $dockerfile_path/puppet/m*
rm -rf $dockerfile_path/Dockerfile
mv $dockerfile_path/Dockerfile.bck $dockerfile_path/Dockerfile
echo "Done."