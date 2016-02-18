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
default_port=32003
km_port=32009
publisher_port=32012
store_port=32014
gateway_port=32007

# Deploy using default profile
function default {
    echo "Deploying wso2am default service..."
    kubectl create -f wso2am-default-service.yaml

    echo "Deploying wso2am default controller..."
    kubectl create -f wso2am-default-controller.yaml

    echo "Waiting wso2am to launch on http://${host}:${default_port}"
    until $(curl --output /dev/null --silent --head --fail http://${host}:${default_port}); do
        printf '.'
        sleep 5
    done

    echo -e "\nwso2am launched!"
}

# Deploy using separate profiles
function distributed {
    echo "Deploying wso2am key manager service..."
    kubectl create -f wso2am-key-manager-service.yaml

    echo "Deploying wso2am store service..."
    kubectl create -f wso2am-store-service.yaml

    echo "Deploying wso2am publisher service..."
    kubectl create -f wso2am-publisher-service.yaml

    echo "Deploying wso2am gateway manager service..."
    kubectl create -f wso2am-gateway-service.yaml

    # deploy the controllers

    echo "Deploying wso2am key manager controller..."
    kubectl create -f wso2am-key-manager-controller.yaml

    echo "Waiting wso2am key manager to launch on http://${host}:${km_port}"
    until $(curl --output /dev/null --silent --head --fail http://${host}:${km_port}); do
        printf '.'
        sleep 5
    done

    echo -e "\nwso2am key manager launched!"

    echo "Deploying wso2am store controller..."
    kubectl create -f wso2am-store-controller.yaml

    echo "Waiting wso2am store to launch on http://${host}:${store_port}"
    until $(curl --output /dev/null --silent --head --fail http://${host}:${store_port}); do
        printf '.'
        sleep 5
    done

    echo -e "\nwso2am store launched!"

    echo "Deploying wso2am publisher controller..."
    kubectl create -f wso2am-publisher-controller.yaml

    echo "Waiting wso2am publisher to launch on http://${host}:${publisher_port}"
    until $(curl --output /dev/null --silent --head --fail http://${host}:${publisher_port}); do
        printf '.'
        sleep 5
    done

    echo -e "\nwso2am publisher launched!"

    echo "Deploying wso2am gateway manager controller..."
    kubectl create -f wso2am-gateway-controller.yaml

    echo "Waiting wso2am gateway manager to launch on http://${host}:${gateway_port}"
    until $(curl --output /dev/null --silent --head --fail http://${host}:${gateway_port}); do
        printf '.'
        sleep 5
    done

    echo -e "\nwso2am gateway manager launched!"
}

pattern=$1
if [ -z "$pattern" ]
  then
    pattern='default'
fi

if [ "$pattern" = "default" ]; then
  default
elif [ "$pattern" = "distributed" ]; then
  distributed
else
  echo "Usage: ./deploy.sh [default|distributed]"
  exit
fi
