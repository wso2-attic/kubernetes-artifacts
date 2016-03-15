# Kubernetes Artifacts for WSO2 Identity Server #
The Kuberneters Artifacts provides the resources and instructions to deploy the built docker images of WSO2 products in Kubernetes.

## Try it out
Quick steps to run WSO2 Identity Server default profile docker image on Kubernetes

* Prerequisites
    - Ensure default profile of Identity Server docker is built and loaded in the Kubernetes node.
    Instructions on how to build Identity Server docker image and load into the Kubernetes node is explained in [Dockerfile for WSO2 Identity Server](https://github.com/wso2/kubernetes-artifacts/tree/master/wso2is/docker/README.md#building-the-docker-images).

* Deploying Default Profile

    - Navigate to the `kubernetes` folder inside the module wso2is. (eg: `<REPOSITORY_HOME>/wso2is/docker`). 
    - Ensure the node ip is set correctly to `host` in the `deploy.sh`
      Else you can pass the correct host IP as an argument with -h option.
    - Execute `deploy.sh` script and provide the deployment details.
        + `./deploy.sh -d 'default'`

* Access management console
    - Add an etc/hosts entry in your local machine for `<kubernetes_node_ip> is.wso2.com`. For example:
        + `172.17.8.102       is.wso2.com`
    - To access the management console.
        +  `https://is.wso2.com:32002/carbon`. For example, `https://is.wso2.com:32002/carbon`.

## Undeploying

    - Navigate to the `kubernetes` folder inside the module wso2is. (eg: `<REPOSITORY_HOME>/wso2is/docker`).
    - Execute `undeploy.sh` .
        + `./undeploy.sh`           
* The `undeploy.sh` script has the following profiles defined to be undeployed. If it is required to undeploy any other profile, then it can be added to the `product_profiles` with a space as the separator.
    - `product_profiles=(default)`
