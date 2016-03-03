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

local_ip=$(ip route get 1 | awk '{print $NF;exit}')
server_path=/mnt/${local_ip}
echo "Creating directory $server_path..."
mkdir -p "${server_path}"

server_name=${WSO2_SERVER}-${WSO2_SERVER_VERSION}
echo "Moving carbon server from /mnt/${server_name} to ${server_path}..."
mv "/mnt/${server_name}" "${server_path}/"

axis2_xml_file_path=${server_path}/${server_name}/repository/conf/axis2/axis2.xml

# replace localMemberHost with local ip
function replace_local_member_host_with_ip {
    sed -i "s/\(<parameter\ name=\"localMemberHost\">\).*\(<\/parameter*\)/\1$local_ip\2/" "${axis2_xml_file_path}"
    if [[ $? == 0 ]];
    then
        echo "successfully updated localMemberHost with local ip address $local_ip"
    else
        echo "error occurred in updating localMemberHost with local ip address $local_ip"
    fi
}

replace_local_member_host_with_ip

export CARBON_HOME="${server_path}/${server_name}"
echo "Starting ${WSO2_SERVER}..."
${CARBON_HOME}/bin/wso2server.sh

# carbon_xml_file_path=${server_path}/${server_name}/repository/conf/carbon.xml

# add host mapping
# $1 = hostname
# $2 = ip address
# function add_host_mapping {
#     if [[ ! -z $1 && $1 != $2 ]];
#     then
#         echo "$2    $1" >> /etc/hosts
#         echo "added host mapping for $1 -> $2"
#     fi
# }

# grep and return 'HostName' from carbon.xml
# function get_hostname_from_carbon_config {
#     echo `grep -oP "(?<=<HostName>).*?(?=</HostName>)" $carbon_xml_file_path`
# }

#
## check if this is localhost ip
#function is_localhost {
#    if [[ $1 = '127.0.0.1' ]];
#    then
#	    return 0
#    else
#	    return 1
#    fi
#}
#
## validate ip address
#function is_valid_ip_address {
#    if [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]];
#    then
#        echo "detected $1 as a valid ip"
#        return 0
#    else
#	echo "$1 is not a valid ip"
#        return 1
#    fi
#}
#
## check if hostname is defined in /etc/hosts
#function is_hostname_defined_in_hosts_file {
#    if [[ ! -z $1 && ! -z `grep -oP "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(?=.*$1)" /etc/hosts` ]];
#    then
#	echo "hostname $1 is defined in /etc/hosts file"
#        return 0
#    else
#        echo "hostname $1 is not defined in /etc/hosts file"
#        return 1
#    fi
#}
#
## check if hostname resolves to an IP
#function hostname_resolves_to_valid_ip {
#    if [[ ! -z `dig +short $1` ]];
#    then
#	echo "hostname $1 resolves to a valid ip"
#        return 0
#    else
#	echo "hostname $1 does not resolve to a valid ip"
#        return 1
#    fi
#}

# replace localMemberHost with local ip
function replace_local_member_host_with_ip {
    sed -i "s/\(<parameter\ name=\"localMemberHost\">\).*\(<\/parameter*\)/\1$local_ip\2/" $axis2_xml_file_path
    if [[ $? == 0 ]];
    then
        echo "successfully updated localMemberHost with local ip address $local_ip"
    else
        echo "error occurred in updating localMemberHost with local ip address $local_ip"
    fi
}

replace_local_member_host_with_ip

#add_host_mapping "$(get_hostname_from_carbon_config)" "$local_ip"

# echo "JAVA_HOME=${JAVA_HOME}" >> /etc/environment
# echo "CARBON_HOME=${CARBON_HOME}" >> /etc/environment
