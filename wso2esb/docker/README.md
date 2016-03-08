# Dockerfile for WSO2 Enterprise Service Bus #
The Dockerfile define the resources and instructions to build the Docker images with the WSO2 products and runtime configurations. This process uses Puppet and Hiera to update the configuration.

## Try it out
Quick steps to build the WSO2 Enterprise Service Bus docker image and run in your local machine
  
* Get Puppet Modules
    - The Puppet modules for WSO2 products can be found in the [WSO2 Puppet Modules repository](https://github.com/wso2/puppet-modules). You can obtain the latest release from the [releases page](https://github.com/wso2/puppet-modules/releases). 
    - After getting the `wso2-puppet-modules-<version>.zip` file, extract it and set `PUPPET_HOME` environment variable pointing to extracted folder.

* Add product packs and dependencies
    - Download and copy JDK 1.7 ([jdk-7u80-linux-x64.tar.gz](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html)) pack to `<PUPPET_HOME>/modules/wso2base/files`
    - Download the necessary product packs and copy them to `<PUPPET_HOME>/modules/<MODULE>/files`. For example, for WSO2 Enterprise Service Bus 4.9.0 download the [product pack](http://wso2.com/products/enterprise-service-bus/) and copy the zip file to `<PUPPET_HOME>/modules/wso2esb/files`.

* Build the docker image
    - First build the base image by executing `build.sh` script. (eg: `<REPOSITORY_HOME>/common/docker/base-image`)
    - Navigate to the `docker` folder inside the module wso2esb. (eg: `<REPOSITORY_HOME>/wso2esb/docker`).
    - Execute `build.sh` script and provide the product version, image version and the product profiles to be built.
        + `./build.sh 4.9.0 1.0.0 'default'`

* Docker run
    - Execute `run.sh` script and provide the product version, image version and the product profiles to be run.
        + `./run.sh 4.9.0 1.0.0 'default'`

* Access management console
    - Add an etc/hosts entry in your local machine for `<docker_host_ip> esb.wso2.com`. For example:
        + `127.0.0.1       esb.wso2.com`
    -  To access the management console.
        + `https://esb.wso2.com:32004/carbon`

## Building the Docker Images

* Get Puppet Modules
    - The Puppet modules for WSO2 products can be found in the [WSO2 Puppet Modules repository](https://github.com/wso2/puppet-modules). You can obtain the latest release from the [releases page](https://github.com/wso2/puppet-modules/releases). 
    - After getting the `wso2-puppet-modules-<version>.zip` file, extract it and set `PUPPET_HOME` environment variable pointing to extracted folder. 
    - Modify the Hiera files as needed. For example, for WSO2 Enterprise Service Bus 4.9.0, edit the heira data from the profiles found at `wso2-puppet-modules-<version>/heiradata/dev/wso2/wso2esb/4.9.0/` 

* Add product packs and dependencies
    - Download and copy JDK 1.7 ([jdk-7u80-linux-x64.tar.gz](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html)) pack to `<PUPPET_HOME>/modules/wso2base/files`
    - Download the necessary product packs and copy them to `<PUPPET_HOME>/modules/<MODULE>/files`. For example, for WSO2 Enterprise Service Bus 4.9.0 download the [product pack](http://wso2.com/products/enterprise-service-bus/) and copy the zip file to `<PUPPET_HOME>/modules/wso2esb/files`.

* Advanced configuration
    - Copy any deployable artifacts to the wso2esb module's `files` folder. For example, for WSO2 Enterprise Service Bus 4.9.0, copy any deployable applications to `<PUPPET_HOME>/modules/wso2esb/files/configs/repository/deployment/server`.
    - Copy any patches to the wso2esb module's `files` folder. For example, for WSO2 Enterprise Service Bus 4.9.0, copy any patches to `<PUPPET_HOME>/modules/wso2esb/files/patches/repository/components/patches`.
    - For clustering scenario in Kubernetes. Build the [Carbon Kubernetes Membership Scheme](https://github.com/wso2/kubernetes-artifacts/tree/master/common/kubernetes-membership-scheme) and copy the following jar to `<PUPPET_HOME>/modules/wso2esb/files/configs/repository/components/lib` folder. Furthermore, copy the dependencies for the Carbon Kubernetes Membership Scheme to the same place.
        + jackson-annotations-2.5.4.jar
        + jackson-core-2.5.4.jar
        + jackson-databind-2.5.4.jar
        + kubernetes-membership-scheme-1.0.0.jar

* Build the docker images
    - First build the base image by executing `build.sh` script. (eg: `<REPOSITORY_HOME>/common/docker/base-image`)
    - Navigate to the `docker` folder inside the module wso2esb. (eg: `<REPOSITORY_HOME>/wso2esb/docker`).
    - Execute `build.sh` script and provide the product version, image version and the product profiles to be built.
        + `./build.sh 4.9.0 1.0.0 'default|worker|manager'`
    - This will result in Docker images being built for each product profile provided. For example, for WSO2 Enterprise Service Bus, there will be three images named `wso2/esb-4.9.0:1.0.0`, `wso2/esb-manager-4.9.0:1.0.0`, and `wso2/esb-worker-4.9.0:1.0.0` for the command provided above.

## Running the Docker Images

* Docker run
    - Execute `run.sh` script and provide the product version, image version and the product profiles to be run.
        + `./run.sh 4.9.0 1.0.0 'default|worker|manager'`
    - This will result in running the docker images for each product profile provided.
    
## Saving the Docker Images

* Saving the docker images
    - Execute `save.sh` script and provide the product version, image version and the product profiles to be built.
        + `./save.sh 4.9.0 1.0.0 'default|worker|manager'`
    - This will result in saving the tar files for the docker images built for each product profile provided. For example, for WSO2 Enterprise Service Bus, there will be three tar files saved `wso2esb-4.9.0-1.0.0.tar `, `wso2esb-worker-4.9.0-1.0.0.tar `, and `wso2esb-manager-4.9.0-1.0.0.tar ` for the command provided above. 
    - The tar files of the docker images will be saved and found at `~/docker/images` by default.

## Secure copying the Docker Images

* Secure Copy (scp) and the docker images into the node
    - Ensure the node is up
    - Ensure the tar files of the docker images are available at `~/docker/images`
    - Execute `scp.sh` script and provide the node, product version, image version and the product profiles to the secure copied into the node.
        + `./scp.sh core@172.17.8.102 4.9.0 1.0.0 'default|worker|manager'`
    - This will result in sending the tar files into the node and loading the docker image(s) in the node.