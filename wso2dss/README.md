# Kubernetes Artifacts for WSO2 Data Services Server #
The Kubernetes Artifacts provides the resources and instructions to deploy the built docker images of WSO2 products in Kubernetes.

## Try it out
Quick steps to run WSO2 Data Services Server default profile docker image on Kubernetes

* Prerequisites
    - Ensure default profile of Data Services Server docker is built and loaded in the Kubernetes node.
    Instructions on how to build Data Services Server docker image and load into the Kubernetes node is explained in [Dockerfile for WSO2 Data Services Server](https://github.com/wso2/dockerfiles/tree/master/wso2dss/README.md#building-the-docker-images).

* Deploying default profile
    - Ensure the node ip is set correctly to `host` in the `deploy.sh`.
      Else you can pass the correct host IP as an argument with -h option.
    - Execute `deploy.sh` script and provide the deployment details.
        + `./deploy.sh -d 'default'`

* Access management console
    - Add an etc/hosts entry in your local machine for `<kubernetes_node_ip> dss.wso2.com`. For example:
        + `172.17.8.102       dss.wso2.com`
    - To access the management console.
        +  `https://dss.wso2.com:32002/carbon`. For example, `https://dss.wso2.com:32002/carbon`.

## Distributed Deployment
          
* How to deploy in distributed manner
    - Execute `deploy.sh` script and provide the deployment details.
        + `./deploy.sh -d 'distributed'`
    - Distributed deployment will create the following services
        + wso2dss manager
        + wso2dss worker 
    
## Undeploying

* How to undeploy the default or distributed deployment
    - Execute `undeploy.sh` .
        + `./undeploy.sh`

* The `undeploy.sh` script has the following profiles defined to be undeployed. If it is required to undeploy any other profile, then it can be added to the `product_profiles` with a space as the separator.
    - `product_profiles=(default manager worker)`
