# WSO2 Kubernetes Artifacts
WSO2 Kubernetes Artifacts enable you to run WSO2 products seamlessly on [Kubernetes] (https://kubernetes.io) using Docker. This repository contains artifacts (Service and Replication Controller definitions) to deploy WSO2 products on Kubernetes.

## Getting Started
To deploy a WSO2 product on Kubernetes, the following steps have to be done.
* Build relevant Docker images
* Copy the images to the Kubernetes Nodes
* Run `deploy.sh` inside the relevant product folder, which will deploy the Service and the Replication Controllers

##### 1. Build Docker Images

To manage configurations and artifacts when building Docker images, WSO2 recommends to use [`wso2/puppet modules`](https://github.com/wso2/puppet-modules) as the provisioning method. A specific data set for Kubernetes platform is available in wso2 puppet modules. To try out, it's possible to use this data set to build Dockerfiles for wso2 products for Kubernetes with minimum configuration changes.

Buidling WSO2 Dockerfiles using Puppet for Kubernetes:
  1. clone `wso2/puppet modules` and `wso2/dockerfiles` repositories (alternately you can download the released artifacts using the release page of the gitub repository).
  2. copy the [`dependency jars`](https://docs.wso2.com/display/KA100/Kubernetes+Membership+Scheme+for+WSO2+Carbon) for clustering to `PUPPET_HOME/modules/<product>/files/configs/repository/components/lib` location.
  3. set the environment variable `PUPPET_HOME` pointing to location of the puppet modules in local machine. 
  4. navigate to the relevant product directory in the dockerfiles repository; `DOCKERFILES_HOME/<product>`.
  5. build the Dockerfile with the following command:
  
          `./build.sh -v [product-version] -s kubernetes`
          
  note the '-s kubernetes' flag, denoting kubernetes platform.
  
  This will build the standalone product for kubernetes platform, using configuration specified in puppet. Please note its possible to build relevant profiles of the products similarly. Refer build.sh scrip usage.

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

##### 3. Deploy Kubernetes Artifacts
  1. Navigate to `KUBERNETES_ARTIFACTS_HOME/common/wso2-shared-dbs` location.
  2. run the deploy.sh script:
  
            `./deploy.sh`
            
      This will create mysql DB pods for common databases used by WSO2 products. Please note that each kubernetes node needs the mysql:5.5 docker image in the local docker registry.
  3. Navigate to relevant product directory in kubernetes repository; `KUBERNETES_ARTIFACTS_HOME/<product>` location.
  4. run the deploy.sh script:
  
            `\./deploy.sh`
            
      This will deploy the standalone product in Kubernetes, using the image available in kubernetes nodes, and notify once the intended service starts running on the pod. 

> For more detailed instructions on deploying a particular WSO2 product on Kubernetes, refer to the README file in the relevant product folder.

# Documentation
* [Introduction](https://docs.wso2.com/display/KA100/WSO2+Kubernetes+Artifacts)
* [Tutorials](https://docs.wso2.com/display/KA100/Tutorials)
