# Kubernetes Artifacts for WSO2 API Manager #
The Kuberneters Artifacts provides the resources and instructions to deploy the built docker images of WSO2 products in Kubernetes.

## Try it out
Quick steps to run WSO2 API Manager default profile docker image on Kubernetes

* Prerequisites

    - Ensure default profile of API Manager docker is built and loaded in the Kubernetes node.
    Instructions on how to build API Manager docker image and load into the Kubernetes node is explained in [Dockerfile for WSO2 API MANAGER](https://github.com/wso2/kubernetes-artifacts/blob/master/wso2am/docker/README.md#building-the-docker-images).

* Deploying default profile

    - Navigate to the `kubernetes` folder inside the module wso2am. (eg: `<REPOSITORY_HOME>/wso2am/docker`). 
    - Ensure the node ip is set correctly to `host` in the `deploy.sh`. 
      Else you can pass the correct host IP as an argument with -h option.
    - Execute `deploy.sh` script and provide the deployment details.
        + `./deploy.sh -d 'default'`

* Access management console

    - Add an etc/hosts entry in your local machine for `<kubernetes_node_ip> am.wso2.com`. For example:
        + `172.17.8.102       am.wso2.com`
    - To access the management console.
        +  `https://am.wso2.com:32004/carbon`. For example, `https://am.wso2.com:32004/carbon`.

## Distributed Deployment
          
* How to deploy in a distributed manner
    - Navigate to the `kubernetes` folder inside the module wso2am. (eg: `<REPOSITORY_HOME>/wso2am/docker`).
    - Execute `deploy.sh` script and provide the deployment details.
        + `./deploy.sh -d 'distributed'`
    - Distributed deployment will create the following services 
        + wso2am key manager
        + wso2am store
        + wso2am publisher
        + wso2am gateway manager

## Undeploying

* How to undeploy the default or distributed deployment
    - Navigate to the `kubernetes` folder inside the module wso2am. (eg: `<REPOSITORY_HOME>/wso2am/docker`).
    - Execute `undeploy.sh` .
        
* The `undeploy.sh` script has the following profiles defined to be undeployed. If it is required to undeploy any other profile, then it can be added to the `product_profiles` with a space as the separator.
    - `product_profiles=(default api-key-manager api-store api-publisher gateway-manager)`
