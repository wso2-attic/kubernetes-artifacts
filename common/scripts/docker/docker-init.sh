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
set -e

local_ip=`ip route get 1 | awk '{print $NF;exit}'`
server_path=/mnt/${local_ip}
echo "Creating directory $server_path..."
mkdir -p $server_path

server_name=${WSO2_SERVER}-${WSO2_SERVER_VERSION}
echo "Moving carbon server from /mnt/${server_name} to ${server_path}..."
mv /mnt/${server_name} ${server_path}/

# add host mapping
# $1 = hostname
# $2 = ip address
function add_host_mapping {
    if [[ ! -z $1 && $1 != $2 ]];
    then
        echo "$local_ip   $local_member_host" >> /etc/hosts
      else
        echo "localMemberHost is not set | already set to local ip"
    fi
}

# resolve localMemberHost
axis2_file_path=${server_path}/repository/conf/axis2/axis2.xml
local_member_host=`grep -oP "<parameter\ name=\"localMemberHost\">(.*)</parameter>" $axis2_file_path | cut -d ">" -f 2 | cut -d "<" -f 1`
echo "found localMemberhost = $local_member_host"
add_host_mapping "$local_member_host" "$local_ip"

# resolve hostname
#carbon_file_path=${server_path}/repository/conf/carbon.xml
#carbon_hostname=`grep -oP "<HostName>(.*)</HostName>" $carbon_file_path | cut -d ">" -f 2 | cut -d "<" -f 1`
#echo "found carbon host name = $carbon_hostname"
#add_host_mapping $carbon_hostname $local_ip

export CARBON_HOME="${server_path}/${server_name}"

echo "JAVA_HOME=${JAVA_HOME}" >> /etc/environment
echo "CARBON_HOME=${CARBON_HOME}" >> /etc/environment

echo "Starting ${WSO2_SERVER}..."
${CARBON_HOME}/bin/wso2server.sh