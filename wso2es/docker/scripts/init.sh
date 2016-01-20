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
#
# ------------------------------------------------------------------------

local_ip=`awk 'NR==1 {print $1}' /etc/hosts`
server_path=/mnt/${local_ip}
echo "Creating directory $server_path..."
mkdir -p $server_path

server_name=${WSO2_SERVER}-${WSO2_SERVER_VERSION}
echo "Moving carbon server from /mnt/${server_name} to ${server_path}..."
mv /mnt/${server_name} ${server_path}/
export CARBON_HOME="$server_path/${server_name}"

echo "JAVA_HOME=${JAVA_HOME}" >> /etc/environment
echo "CARBON_HOME=${CARBON_HOME}" >> /etc/environment

if [ "${CONFIG_PARAM_PROFILE}" = 'worker' ]; then
    echo "Starting ${WSO2_SERVER} as worker..."
    ${CARBON_HOME}/bin/wso2server.sh -DworkerNode=true
else
    echo "Starting ${WSO2_SERVER} in default profile..."
    ${CARBON_HOME}/bin/wso2server.sh
fi
