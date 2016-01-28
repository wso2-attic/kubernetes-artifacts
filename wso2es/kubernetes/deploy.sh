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
default_port=32001

echo "Deploying wso2es default service..."
kubectl create -f wso2es-default-service.yaml

echo "Deploying wso2es default controller..."
kubectl create -f wso2es-default-controller.yaml

echo "Waiting wso2es to launch on http://${host}:${default_port}"
until $(curl --output /dev/null --silent --head --fail http://${host}:${default_port}); do
    printf '.'
    sleep 5
done

echo -e "\nwso2es launched!"

