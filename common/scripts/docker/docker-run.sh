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

product_name=$1
product_version=$2
image_version=$3
product_profiles=$4

IFS='|' read -r -a array <<< "${product_profiles}"
for profile in "${array[@]}"
do
    name="wso2${product_name}-${profile}"

    if [[ $profile = "default" ]]; then
        container_id=`docker run -d -P --name ${name} wso2/${product_name}-${product_version}:${image_version}`
    else
        container_id=`docker run -d -P --name ${name} wso2/${product_name}-${profile}-${product_version}:${image_version}`
    fi

    member_ip=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${container_id}`
    echo "WSO2 ${product_name^^} ${profile} member started: [name] ${name} [ip] ${member_ip} [container-id] ${container_id}"
    sleep 1

done

echo "To get bash into a running container use following command..."
echo "docker exec -it <containerId or name> bash"