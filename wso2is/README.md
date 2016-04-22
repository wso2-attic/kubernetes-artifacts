# Kubernetes Artifacts for WSO2 Identity Server #
These Kubernetes Artifacts provide the resources and instructions to deploy WSO2 Identity Server on Kubernetes.

## Try it out
Quick steps to run WSO2 Identity Server Docker image in the Standalone mode on Kubernetes.

* Prerequisites
    - Ensure that the default profile of Identity Server Docker image is built and loaded in the Kubernetes node.
    Instructions on how to build Identity Server Docker image is explained in the [Dockerfile for WSO2 Identity Server](https://github.com/wso2/dockerfiles/tree/master/wso2is/README.md#building-the-docker-images). The image can be transfered to the Kubernetes nodes using the `load-images.sh` script.

* Deploying in the Standalone mode
    - The `deploy.sh` script will detect one of the Kubernetes nodes as the host IP, for service health check when the artifacts are deployed. `kubectl` should be working for this to work correctly.
    - Execute `deploy.sh` script.
        + `./deploy.sh`

* Access management console
    - Add an `/etc/hosts` entry in your local machine for `<kubernetes_node_ip> is.wso2.com`. For example:
        + `172.17.8.102       is.wso2.com`
    - To access the management console.
        +  `https://is.wso2.com:32111/carbon`.

## Undeploy script
* To undeploy the Services and the Replication Controllers for the default or distributed deployment, execute `undeploy.sh`.
