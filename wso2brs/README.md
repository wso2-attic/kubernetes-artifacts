# Kubernetes Artifacts for WSO2 Business Rules Server #
The Kuberneters Artifacts provides the resources and instructions to deploy the built docker images of WSO2 products in Kubernetes.

## Try it out
Quick steps to run WSO2 Business Rules Server default profile docker image on Kubernetes

* Prerequisites
    - Ensure default profile of Business Rules Server docker is built and loaded in the Kubernetes node.
    Instructions on how to build Business Rules Server docker image and load into the Kubernetes node is explained in [Dockerfile for WSO2 Business Rules Server](https://github.com/wso2/dockerfiles/blob/master/wso2brs/README.md#building-the-docker-images).

* Deploying default profile
    - Ensure that `host` in the `deploy.sh` is set correctly to the node IP  
    - Execute `deploy.sh` script and provide the deployment details.
        + `./deploy.sh -d 'default'`

* Access management console
    - Add an `etc/hosts` entry in your local machine for `<kubernetes_node_ip> brs.wso2.com`. For example:
        + `172.17.8.102       brs.wso2.com`
    - To access the management console.
        +  `https://brs.wso2.com:32004/carbon`. For example, `https://brs.wso2.com:32004/carbon`.

## Distributed Deployment

* How to deploy in a distributed manner
    - Apply Kubernetes Membership Scheme as described in [here](https://docs.wso2.com/display/KA100/Kubernetes+Membership+Scheme+for+WSO2+Carbon)
    - Execute `deploy.sh` script and provide the deployment details.
        + `./deploy.sh -d 'distributed'`
    - Distributed deployment will create the following services
        + wso2brs manager
        + wso2brs worker

## Undeploy script

* How to undeploy the default or distributed deployment
    - Execute `undeploy.sh` .
          + `./undeploy.sh`

* The `undeploy.sh` script has the following profiles that will be undeployed by default.. If it is required to undeploy any other profile, then it can be added to the `product_profiles` with a space as the separator.
    - `product_profiles=(default manager worker)`
