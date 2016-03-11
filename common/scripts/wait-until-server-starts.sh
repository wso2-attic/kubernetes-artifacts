#!/bin/bash
# ------------------------------------------------------------------------
#
# Copyright 2016 WSO2, Inc. (http://wso2.com)
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

product=$1
profile=$2
host=$3
port=$4

echo "Waiting ${product} to launch on http://${host}:${port}"
until $(curl --output /dev/null --silent --head --fail http://${host}:${port}); do
    printf '.'
    sleep 5
done

echo -e "\nCarbon Server ${product} started successfully, profile: ${profile}"
