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

function echoError () {
    echo $'\e[1;31m'"${1}"$'\e[0m'
}

function echoSuccess () {
    echo $'\e[1;32m'"${1}"$'\e[0m'
}

function echoBold () {
    echo $'\e[1m'"${1}"$'\e[0m'
}

# Show usage and exit
function showUsageAndExit() {
    echoBold "Usage: ./build.sh [product-version] [docker-image-version] [product_profile_list]"
    echo "Ex: ./build.sh 1.9.1 1.0.0 'default|worker|manager'"
    exit 1
}

function cleanup () {
    echoBold "Cleaning..."
    rm -rf $dockerfile_path/scripts
    rm -rf $dockerfile_path/puppet
}

dockerfile_path=$1
image_version=$2
product_name=$3
product_version=$4
product_profiles=$5
product_env=$6

prgdir2=`dirname "$0"`
self_path=`cd "$prgdir2"; pwd`

# Validate mandatory args
if [ -z "$product_version" ]
  then
    showUsageAndExit
fi

if [ -z "$image_version" ]
  then
    showUsageAndExit
fi

if [ -z "$product_profiles" ]
  then
    product_profiles="default"
fi

if [ -z "$product_env" ]; then
    product_env="dev"
fi

# Check if a Puppet folder is set
if [ -z "$PUPPET_HOME" ]; then
   echoError "Puppet home folder could not be found! Set PUPPET_HOME environment variable pointing to local puppet folder."
   exit 1
else
   puppet_path=$PUPPET_HOME
   echoBold "PUPPET_HOME is set to ${puppet_path}."
fi

# Copy common files to Dockerfile context
echoBold "Creating Dockerfile context..."
mkdir -p $dockerfile_path/scripts
mkdir -p $dockerfile_path/puppet/modules
cp $self_path/docker-init.sh $dockerfile_path/scripts/init.sh

echoBold "Copying Puppet modules to Dockerfile context..."
cp -r $puppet_path/modules/wso2base $dockerfile_path/puppet/modules/
cp -r $puppet_path/modules/wso2${product_name} $dockerfile_path/puppet/modules/
cp -r $puppet_path/hiera* $dockerfile_path/puppet/
cp -r $puppet_path/manifests $dockerfile_path/puppet/

# Build image for each profile provided
IFS='|' read -r -a array <<< "${product_profiles}"
for profile in "${array[@]}"
do
    if [[ $profile = "default" ]]; then
        image_id="wso2/${product_name}-${product_version}:${image_version}"
    else
        image_id="wso2/${product_name}-${profile}-${product_version}:${image_version}"
    fi

    echoBold "Building docker image ${image_id}..."

    {
        ! docker build --no-cache=true \
        --build-arg WSO2_SERVER=wso2${product_name} \
        --build-arg WSO2_SERVER_VERSION=${product_version} \
        --build-arg WSO2_SERVER_PROFILE=${profile} \
        --build-arg WSO2_ENVIRONMENT=${product_env} \
        -t ${image_id} $dockerfile_path | grep -i error && echoBold "Docker image ${image_id} created."
    } || {
        echoError "ERROR: Docker image ${image_id} creation failed"
        cleanup
        exit 1
    }

done

cleanup
echoSuccess "Build process completed"
