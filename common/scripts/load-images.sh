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
self_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${self_path}/base.sh"

function showUsageAndExit() {
        echoBold "Usage: ./load-images.sh [OPTIONS]"
        echo
        echo "Transfer Docker images to Kubernetes Nodes"

        echoBold "Options:"
        echo
        echo -en "  -u\t"
        echo "[OPTIONAL] Username to be used to connect to Kubernetes Nodes. If not provided, default \"core\" is used."
        echo -en "  -p\t"
        echo "[OPTIONAL] Optional search pattern to search for Docker images. If not provided, default \"wso2\" is used."
        echo -en "  -h\t"
        echo "[OPTIONAL] Show help text."
        echo

        echoBold "Ex: ./load-images.sh"
        echoBold "Ex: ./load-images.sh -u ubuntu"
        echoBold "Ex: ./load-images.sh -p wso2is"
        echo
        exit 1
}

validateKubeCtlConfig

kub_username="core"
search_pattern="wso2"
IFS=$'\n'

kube_nodes=($(kubectl get nodes | awk '{if (NR!=1) print $1}'))
if [ "${#kube_nodes[@]}" -lt 1 ]; then
    echoError "No Kubernetes Nodes found."
    exit 1
fi

# TODO: handle flag provided, but no value
while getopts :u:p:h FLAG; do
    case $FLAG in
        u)
            kub_username=$OPTARG
            ;;
        p)
            search_pattern=$OPTARG
            ;;
        h)
            showUsageAndExit
            ;;
    esac
done

wso2_docker_images=($(sudo docker images | grep "${search_pattern}" | awk '{print $1 ":" $2}'))

if [ "${#wso2_docker_images[@]}" -lt 1 ]; then
    echo "No Docker images with name \"wso2\" found."
    exit 1
fi

for wso2_image_name in "${wso2_docker_images[@]}"
do
    if [ "${wso2_image_name//[[:space:]]/}" != "" ]; then
        wso2_image=$(sudo docker images $wso2_image_name | awk '{if (NR!=1) print}')
        echo -n $(echo $wso2_image | awk '{print $1 ":" $2, "(" $3 ")"}') " - "
        askBold "Transfer? (y/n): "
        read -r xfer_v
        if [ "$xfer_v" == "y" ]; then
            image_id=$(echo $wso2_image | awk '{print $3}')
            echoDim "Saving image ${wso2_image_name}..."
            sudo docker save $image_id > /tmp/$image_id.tar

            for kube_node in "${kube_nodes[@]}"
            do
                echoDim "Copying saved image to ${kube_node}..."
                scp /tmp/$image_id.tar $kub_username@$kube_node:.
                echoDim "Loading copied image..."
                ssh $kub_username@$kube_node "docker load < ${image_id}.tar"
                ssh $kub_username@$kube_node "rm -rf ${image_id}.tar"
            done

            echoDim "Cleaning..."
            rm -rf /tmp/$image_id.tar
            echoBold "Done"
        fi
    fi
done
