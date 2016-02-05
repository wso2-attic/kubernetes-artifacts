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

host=10.245.1.3
#host=172.17.8.102
publisher_port=32001
store_port=32003

# deploy store
echo "Deploying wso2es store service..."
kubectl create -f wso2es-store-service.yaml

echo "Deploying wso2es store controller..."
kubectl create -f wso2es-store-controller.yaml

echo "Waiting wso2es to launch on http://${host}:${store_port}"
until $(curl --output /dev/null --silent --head --fail http://${host}:${store_port}); do
    printf '.'
    sleep 5
done

echo -e "\nwso2es store launched!"

# deploy publisher
echo "Deploying wso2es publisher service..."
kubectl create -f wso2es-publisher-service.yaml

echo "Deploying wso2es publisher controller..."
kubectl create -f wso2es-publisher-controller.yaml

echo "Waiting wso2es to launch on http://${host}:${publisher_port}"
until $(curl --output /dev/null --silent --head --fail http://${host}:${publisher_port}); do
    printf '.'
    sleep 5
done

echo -e "\nwso2es publisher launched!"
