# Kubernetes Artifacts for WSO2 API Manager #
These Kubernetes Artifacts provide the resources and instructions to deploy WSO2 API Manager on Kubernetes.

Note: In the context of this document, `KUBERNETES_HOME`, `DOCKERFILES_HOME` and `PUPPET_HOME` will refer to local copies of [`wso2/kubernetes artifacts`](https://github.com/wso2/kubernetes-artifacts/), [`wso2/dockcerfiles`](https://github.com/wso2/dockerfiles/) and [`wso2/puppet modules`](https://github.com/wso2/puppet-modules) repositories respectively.

## Getting Started
To deploy a WSO2 API Manager on Kubernetes, the following steps have to be done.
* Build Docker images for WSO2 API Manager
* Copy the images to the Kubernetes Nodes
* Run `deploy.sh` inside the `KUBERNETES_HOME/wso2am` directory, which will deploy the Service and the Replication Controllers

##### 1. Build API Manager Docker Images

To manage configurations and artifacts when building Docker images, WSO2 recommends to use [`wso2/puppet modules`](https://github.com/wso2/puppet-modules) as the provisioning method. A specific data set for Kubernetes platform is available in wso2 puppet modules. To try out, it's possible to use this data set to build Dockerfiles for wso2 products for Kubernetes with minimum configuration changes.

Buidling WSO2 API Manager Dockerfile using Puppet, for Kubernetes:

  1. Clone `wso2/puppet modules` and `wso2/dockerfiles` repositories (alternatively you can download the released artifacts using the release page of the GitHub repository).
  2. Copy the [`dependency jars`](https://docs.wso2.com/display/KA100/Kubernetes+Membership+Scheme+for+WSO2+Carbon) for clustering to `PUPPET_HOME/modules/wso2am/files/configs/repository/components/lib` location.
  3. Copy the JDK [`jdk-7u80-linux-x64.tar.gz`](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html) to `PUPPET_HOME/modules/wso2base/files` location.
  4. Copy the product zip file to `PUPPET_HOME/modules/wso2am/files` location.
  3. Set the environment variable `PUPPET_HOME` pointing to location of the puppet modules in local machine.
  4. Navigate to the relevant product directory in the dockerfiles repository; `DOCKERFILES_HOME/wso2am`.
  5. Build the Dockerfile with the following command:

    **`./build.sh -v 1.10.0 -s kubernetes`**

  Note that `-s kubernetes` flag denotes the Kubernetes platform, when it comes to selecting the configuration from Puppet.

  This will build the standalone WSO2 API Manager for Kubernetes platform, using configuration specified in Puppet. Please note it's possible to build relevant profiles of the products similarly. Refer `build.sh` script usage (`./build.sh -h`).


##### 2. Copy the Images to Kubernetes Nodes/Registry

Copy the required Docker images over to the Kubernetes Nodes (ex: use `docker save` to create a tarball of the required image, `scp` the tarball to each node, and use `docker load` to reload the images from the copied tarballs on the nodes). Alternatively, if a private Docker registry is used, transfer the images there.

You can make use of the `load-images.sh` helper script to transfer images to the Kubernetes nodes. It will search for any Docker images with `wso2` as a part of its name on your local machine, and ask for verification to transfer them to the Kubernetes nodes. `kubectl` has to be functioning on your local machine in order for the script to retrieve the list of Kubernetes nodes. You can optionally provide a search pattern if you want to override the default `wso2` string.

**`load-images.sh`
Usage**
```
Usage: ./load-images.sh [OPTIONS]

Transfer Docker images to Kubernetes Nodes
Options:

  -u	[OPTIONAL] Username to be used to connect to Kubernetes Nodes. If not provided, default "core" is used.
  -p	[OPTIONAL] Optional search pattern to search for Docker images. If not provided, default "wso2" is used.
  -h	[OPTIONAL] Show help text.

Ex: ./load-images.sh
Ex: ./load-images.sh -u ubuntu
Ex: ./load-images.sh -p wso2is
```

##### 3. Deploy API Manager Kubernetes Artifacts
  1. Navigate to wso2am directory in kubernetes repository; `KUBERNETES_ARTIFACTS_HOME/wso2am` location.
  2. run the deploy.sh script:

    **`./deploy.sh`**

      This will deploy the standalone product in Kubernetes, using the image available in kubernetes nodes, and notify once the intended service starts running on the pod.
      __Please note that each kubernetes node needs the [`mysql:5.5`](https://hub.docker.com/_/mysql/) docker image in the node's docker registry.__

##### 4. Access Management Console
  1. Add an host entry (in Linux, using the /etc/hosts file) for `wso2am-default`, resolving to the kubernetes node IP.
  2. Access the Mgt Console URL using `https://wso2am-default:32004/carbon/`. 
    * Publisher URL: `https://wso2am-default:32004/publisher`
    * Store URL: `https://wso2am-default:32004/store`
    * API endpoint URL: `https://wso2am-default:32002/<api_name>`.

##### 5. Undeploying
  1. Navigate to wso2am directory in kubernetes repository; `KUBERNETES_ARTIFACTS_HOME/wso2am` location.
  2. run the undeploy.sh script:

    **`./undeploy.sh`**

      This will undeploy the API Manager specific DB pod, kubernetes replication controllers and kubernetes services.  

> For more detailed instructions on deploying WSO2 API Manager on Kubernetes, please refer the wiki.

# Documentation
* [Introduction](https://docs.wso2.com/display/KA100/WSO2+Kubernetes+Artifacts)
* [Tutorials](https://docs.wso2.com/display/KA100/Tutorials)
