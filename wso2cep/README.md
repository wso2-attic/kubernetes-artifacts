# Kubernetes Artifacts for WSO2 Complex Event Processor #
These Kubernetes Artifacts provide the resources and instructions to deploy WSO2 Complex Event Processor on Kubernetes.

## Try it out
Quick steps to run WSO2 Complex Event Processor Docker image in the Standalone mode on Kubernetes.

* Prerequisites
    - Ensure that the default profile of Complex Event Processor Docker image is built and loaded in the Kubernetes node.
    Instructions on how to build Complex Event Processor Docker image is explained in the [Dockerfile for WSO2 Complex Event Processor](https://github.com/wso2/dockerfiles/tree/master/wso2cep/README.md#building-the-docker-images). The image can be transfered to the Kubernetes nodes using the `load-images.sh` script.

* Deploying in the Standalone mode
    - The `deploy.sh` script will detect one of the Kubernetes nodes as the host IP, for service health check when the artifacts are deployed. `kubectl` should be working for this to work correctly.
    - Execute `deploy.sh` script.
        + `./deploy.sh`

* Access management console
    - Add an `/etc/hosts` entry in your local machine for `<kubernetes_node_ip> cep.wso2.com`. For example:
        + `172.17.8.102       cep.wso2.com`
    - To access the management console.
        +  `https://cep.wso2.com:32053/carbon`.

## Distributed Deployment

* How to deploy in a distributed manner
    - Apply Kubernetes Membership Scheme as described in [here](https://docs.wso2.com/display/KA100/Kubernetes+Membership+Scheme+for+WSO2+Carbon)
    - Execute `deploy.sh` script with the `-d` flag that deploys the product in the clustered distributed mode.
          + `./deploy.sh -d`
    - Distributed deployment will create the following services
        + `wso2cep presenter`
        + `wso2cep worker`

## Undeploy script
* To undeploy the Services and the Replication Controllers for the default or distributed deployment, execute `undeploy.sh`.

* The `undeploy.sh` script has the following profiles that will be undeployed by default. If it is required to undeploy any other profile, then it can be added to the `product_profiles` variable with a space as the separator.
    - `product_profiles=(default presenter worker)`
