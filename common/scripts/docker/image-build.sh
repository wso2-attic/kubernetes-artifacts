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
product_env=$6

prgdir2=`dirname "$0"`
self_path=`cd "$prgdir2"; pwd`

if [ -z "$PUPPET_HOME" ]; then
   echo "Puppet home folder could not be found! Set PUPPET_HOME environment variable pointing to local puppet folder."
   exit
else
   puppet_path=$PUPPET_HOME
   echo "PUPPET_HOME is set to ${puppet_path}."
fi

if [ -z "$product_env" ]; then
    product_env="dev"
fi

# Copy common files to Dockerfile context
echo "Creating Dockerfile context..."
mkdir -p $dockerfile_path/scripts
mkdir -p $dockerfile_path/puppet/modules
cp $self_path/docker-init.sh $dockerfile_path/scripts/init.sh

echo
echo
echo "Copying Puppet modules to Dockerfile context..."
cp -r $puppet_path/modules/wso2base $dockerfile_path/puppet/modules/
cp -r $puppet_path/modules/wso2${product_name} $dockerfile_path/puppet/modules/
cp -r $puppet_path/hiera* $dockerfile_path/puppet/
cp -r $puppet_path/manifests $dockerfile_path/puppet/

IFS='|' read -r -a array <<< "${profiles}"
for profile in "${array[@]}"
do
    if [[ $profile = "default" ]]; then
        image_id="wso2/${product_name}-${product_version}:${image_version}"
    else
        image_id="wso2/${product_name}-${profile}-${product_version}:${image_version}"
    fi

    echo
    echo
    echo "Building docker image ${image_id}..."

    {
        docker build --no-cache=true --build-arg WSO2_SERVER=wso2${product_name} \
        --build-arg WSO2_SERVER_VERSION=${product_version} \
        --build-arg WSO2_SERVER_PROFILE=${profile} \
        --build-arg WSO2_ENVIRONMENT=${product_env} \
        -t ${image_id} $dockerfile_path && echo "Docker image ${image_id} created."
    } || {
        echo "ERROR: Docker image ${image_id} creation failed"
    }

done

echo
echo
echo "Cleaning..."
rm -rf $dockerfile_path/scripts
rm -rf $dockerfile_path/puppet
# rm -rf $dockerfile_path/Dockerfile
# mv $dockerfile_path/Dockerfile.bck $dockerfile_path/Dockerfile
# chown $dfile_user:$dfile_group $dockerfile_path/Dockerfile
echo "Build process completed"
