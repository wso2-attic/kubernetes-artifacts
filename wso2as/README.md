# Kubernetes Artifacts for WSO2 Application Server #
The Kuberneters Artifacts provides the resources and instructions to deploy the built docker images of WSO2 products in Kubernetes.

## Try it out
Quick steps to run WSO2 Application Server default profile docker image on Kubernetes

* Prerequisites
    - Ensure default profile of Application Server docker is built and loaded in the Kubernetes node.
    Instructions on how to build Application Server docker image and load into the Kubernetes node is explained in [Dockerfile for WSO2 Application Server](https://github.com/wso2/kubernetes-artifacts/tree/master/wso2as/docker/README.md#building-the-docker-images).

* Deploying default profile
    - Navigate to the `kubernetes` folder inside the module wso2as. (eg: `<REPOSITORY_HOME>/wso2as/docker`). 
    - Ensure the node ip is set correctly to `host` in the `deploy.sh`
    - Execute `deploy.sh` script and provide the deployment details.
        + `./deploy.sh -d 'default'`

* Access management console
    - Add an etc/hosts entry in your local machine for `<kubernetes_node_ip> as.wso2.com`. For example:
        + `172.17.8.102       as.wso2.com`
    - To access the management console.
        +  `https://<kubernetes_node_ip>:32004/carbon`. For example, `https://172.17.8.102:32004/carbon`.

## Distributed Deployment
          
* How to deploy in a distributed manner
    - Navigate to the `kubernetes` folder inside the module wso2as. (eg: `<REPOSITORY_HOME>/wso2as/docker`).
    - Execute `deploy.sh` script and provide the deployment details.
        + `./deploy.sh -d 'distributed'`
    - Distributed deployment will create the following services
        + wso2as manager
        + wso2as worker 
    
## Undeploy script

* How to undeploy the default or distributed deployment
    - Navigate to the `kubernetes` folder inside the module wso2as. (eg: `<REPOSITORY_HOME>/wso2as/docker`).
    - Execute `undeploy.sh` .
          + `./undeploy.sh`           
* The `undeploy.sh` script has the following profiles defined to be undeployed. If it is required to undeploy any other profile, then it can be added to the `product_profiles` with a space as the separator.
    - `product_profiles=(default worker manager)`
