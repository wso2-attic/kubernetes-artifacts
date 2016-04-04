# Kubernetes Artifacts for WSO2 API Manager #
The Kubernetes Artifacts provide the resources and instructions to deploy WSO2 API Manager on Kubernetes.

## Try it out
Quick steps to run WSO2 API Manager default profile Docker image on Kubernetes

* Prerequisites
    - Ensure default profile of API Manager Docker image is built and loaded in the Kubernetes node.
    Instructions on how to build API Manager Docker image and load it to the Kubernetes node is explained in [here](https://github.com/wso2/dockerfiles/blob/master/wso2am/README.md#try-it-out).

* Deploying default profile
    - Ensure that `host` in the `deploy.sh` is set correctly to the node IP. Alternatively you can pass the correct host IP as an argument with `-h` option.
    - Execute `deploy.sh` script and provide the deployment details.
        + `./deploy.sh -d 'default'`

* Access management console
    - Add an `/etc/hosts` entry in your local machine for `<kubernetes_node_ip> am.wso2.com`. For example:
        + `172.17.8.102       am.wso2.com`
    - To access the management console.
        +  `https://am.wso2.com:32004/carbon`. For example, `https://am.wso2.com:32004/carbon`.

## Distributed Deployment

* How to deploy in a distributed manner
    - Apply Kubernetes Membership Scheme as described in [here](https://docs.wso2.com/display/KA100/Kubernetes+Membership+Scheme+for+WSO2+Carbon)
    - Execute `deploy.sh` script and provide the deployment details.
        + `./deploy.sh -d 'distributed'`
    - Distributed deployment will create the following services
        + `wso2am-key-manager`
        + `wso2am-store`
        + `wso2am-publisher`
        + `wso2am-gateway-manager`

## Undeploying
* To undeploy the default or distributed deployment execute `undeploy.sh`.

* The `undeploy.sh` script has the following profiles that will be undeployed by default. If it is required to undeploy any other profile, then it can be added to the `product_profiles` with a space as the separator.
    - `product_profiles=(default api-key-manager api-store api-publisher gateway-manager)`
