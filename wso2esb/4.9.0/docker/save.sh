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

if [ -z "$1" ]
  then
    echo "Usage: ./save.sh [docker-image-version]"
    exit
fi

image_version=$1
image_id="wso2/esb-4.9.0:${image_version}"
tar_file="wso2esb-4.9.0-${image_version}.tar"

echo "Saving docker image ${image_id} to ~/docker/images/${tar_file}"
docker save ${image_id} > ~/docker/images/${tar_file}
