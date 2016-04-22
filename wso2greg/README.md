# Kubernetes Artifacts for WSO2 Governance Registry #
These Kubernetes Artifacts provide the resources and instructions to deploy WSO2 Governance Registry on Kubernetes.

## Try it out
Quick steps to run WSO2 Governance Registry Docker image in the Standalone mode on Kubernetes.

* Prerequisites
    - Ensure that the default profile of Governance Registry Docker image is built and loaded in the Kubernetes node.
    Instructions on how to build Governance Registry Docker image is explained in the [Dockerfile for WSO2 Governance Registry](https://github.com/wso2/dockerfiles/tree/master/wso2greg#building-the-docker-images). The image can be transfered to the Kubernetes nodes using the `load-images.sh` script.

* Deploying in the Standalone mode
    - The `deploy.sh` script will detect one of the Kubernetes nodes as the host IP, for service health check when the artifacts are deployed. `kubectl` should be working for this to work correctly.
    - Execute `deploy.sh` script.
        + `./deploy.sh`

* Access management console
    - Add an `/etc/hosts` entry in your local machine for `<kubernetes_node_ip> greg.wso2.com`. For example:
        + `172.17.8.102       greg.wso2.com`
    - To access the management console.
        +  `https://greg.wso2.com:32101/carbon`.

## Distributed Deployment

* How to deploy in a distributed manner
    - Apply Kubernetes Membership Scheme as described in [here](https://docs.wso2.com/display/KA100/Kubernetes+Membership+Scheme+for+WSO2+Carbon)
    - Execute `deploy.sh` script with the `-d` flag that deploys the product in the clustered distributed mode.
        + `./deploy.sh -d`
    - Distributed deployment will create the following services
        + `wso2greg publisher`
        + `wso2greg store`

## Undeploy script
* To undeploy the Services and the Replication Controllers for the default or distributed deployment, execute `undeploy.sh`.

* The `undeploy.sh` script has the following profiles that will be undeployed by default. If it is required to undeploy any other profile, then it can be added to the `product_profiles` variable with a space as the separator.
    - `product_profiles=(default publisher store)`
