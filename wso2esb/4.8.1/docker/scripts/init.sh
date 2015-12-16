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
mkdir -p $server_path
unzip /opt/wso2${WSO2_SERVER_TYPE}-${WSO2_SERVER_VERSION}.zip -d $server_path
rm /opt/wso2${WSO2_SERVER_TYPE}-${WSO2_SERVER_VERSION}.zip

export CARBON_HOME="$server_path/wso2${WSO2_SERVER_TYPE}-${WSO2_SERVER_VERSION}"
export CONFIG_PARAM_LOCAL_MEMBER_HOST=${local_ip}

echo "JAVA_HOME=${JAVA_HOME}" >> /etc/environment
echo "CARBON_HOME=${CARBON_HOME}" >> /etc/environment

echo "Copying server artifacts..."
cp -vr /opt/artifacts/* ${CARBON_HOME}/

if [ "${CONFIG_PARAM_PROFILE}" = 'worker' ]; then
    echo "Starting wso2 ${WSO2_SERVER_TYPE} as worker..."
    ${CARBON_HOME}/bin/wso2server.sh -DworkerNode=true
else
    echo "Starting wso2 ${WSO2_SERVER_TYPE} as manager..."
    ${CARBON_HOME}/bin/wso2server.sh
fi

