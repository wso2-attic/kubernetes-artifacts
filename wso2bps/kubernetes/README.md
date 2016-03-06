# Kubernetes Artifacts for WSO2 Business Process Server #
The Dockerfile define the resources and instructions to build the Docker images with the WSO2 products and runtime configurations. This process uses Puppet and Hiera to update the configuration.

## Try it out
Quick steps to run WSO2 Business Process Server default profile docker image on Kubernetes

* Prerequisites
    - Ensure default profile of Business Process Server docker is built and loaded in the Kubernetes node.
    Instructions on how to build Business Process Server docker image and load into the Kubernetes node is explained in [Dockerfile for WSO2 Business Process Server](https://github.com/wso2/kubernetes-artifacts/tree/master/wso2bps/docker).

* Deploying default profile
    - Navigate to the `kubernetes` folder inside the module wso2bps. (eg: `<REPOSITORY_HOME>/wso2bps/docker`). 
    - Ensure the node ip is set correctly to `host` in the `deploy.sh`
    - Execute `deploy.sh` script and provide the deployment details.
        + `./deploy.sh 'default'`

* Access management console
    - Add an etc/hosts entry in your local machine for `<kubernetes_node_ip> bps.wso2.com`. For example:
        + `172.17.8.102       bps.wso2.com`
    - To access the management console.
        +  `https://<kubernetes_node_ip>:32004/carbon`. For example, `https://172.17.8.102:32004/carbon`.

## Deploy script

* How to deploy the default deployment
    - Navigate to the `kubernetes` folder inside the module wso2bps. (eg: `<REPOSITORY_HOME>/wso2bps/docker`).
    - Ensure the node ip is set correctly to `host` in the `deploy.sh`
    - Execute `deploy.sh` script and provide the deployment details.
          + `./deploy.sh 'default'`
          
* How to deploy the distributed deployment
    - Navigate to the `kubernetes` folder inside the module wso2bps. (eg: `<REPOSITORY_HOME>/wso2bps/docker`).
    - Execute `deploy.sh` script and provide the deployment details.
          + `./deploy.sh 'distributed'`
    
## Undeploy script

* How to undeploy the default or distributed deployment
    - Navigate to the `kubernetes` folder inside the module wso2bps. (eg: `<REPOSITORY_HOME>/wso2bps/docker`).
    - Execute `undeploy.sh` .
          + `./undeploy.sh`           
* The `undeploy.sh` script has the following profiles defined to be undeployed. If it is required to undeploy any other profile, then it can be added to the `product_profiles` with a space as the separator.
    - `product_profiles=(default worker manager)`
