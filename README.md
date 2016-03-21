# WSO2 Kubernetes Artifacts

This repository contains artifacts for deploying WSO2 products on [Kubernetes] (https://kubernetes.io):

## Get started with WSO2 Kubernetes Artifacts

If you are new to using WSO2 Kubernetes Artifacts, follow the steps given below to get started:

## Get familiar

Kubernetes Service artifacts and Replication Controller artifacts are provided for the WSO2 products inside `<REPOSITORY_HOME>/<WSO2_PRODUCT>`.

[Understand](https://docs.wso2.com/display/KA100/Introduction) the basics of the KA and its architecture.

##	Quick Start Guide
###### Note: This Quick Start Guide is based on How to deploy WSO2 ESB in Kubernetes. For instructions on other products, refer the README inside each product. <br><br>
  - Download latest wso2-puppet-modules release and configure.
  <br>
   `wget  https://github.com/wso2/puppet-modules/releases/download/v1.1.1/wso2-puppet-modules-1.1.1.zip` <br>

      `unzip wso2-puppet-modules-1.1.1.zip -d /etc/puppet` <br>

      `export PUPPET_HOME=/etc/puppet`<br>

  - Download JDK 1.7 and WSO2 product
  <br>
      `wget http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html` <br></br>
      `cp jdk-7u80-linux-x64.tar.gz <PUPPET_HOME>/modules/wso2base/files`  <br></br>
      `wget http://wso2.com/products/enterprise-service-bus`  <br></br>
      `cp wso2esb-4.9.0.zip  <PUPPET_HOME>/modules/wso2esb/files`  <br></br>

  - Download latest wso2 dockerfiles and build docker images, save and scp to K8S. Assumes you have a K8S node running in 172.17.8.102 <br>
    `wget https://github.com/wso2/dockerfiles/releases/download/v1.0.0/wso2-dockerfiles-1.0.0.zip` <br>

    `unzip wso2-dockerfiles-1.0.0.zip -d /opt/dockerfiles` <br>

    `export DOCKERFILES_HOME=/opt/dockerfiles/wso2-dockerfiles-1.0.0`

    `cd $DOCKERFILES_HOME/common/base` <br>

    `./build.sh` <br>

    `cd $DOCKERFILES_HOME/wso2esb` <br>

    `./build.sh -v 4.9.0 -i 1.0.0` <br>

    `./save.sh -v 4.9.0 -i 1.0.0`

    `./scp.sh -h 'core@172.17.8.102' -v 4.9.0 -i 1.0.0`

  - Download latest kubernetes artifacts (This repository) and deploy <br>
      `cd <REPOSITORY_HOME>/wso2esb` <br>

      `./deploy.sh -d default`


##	Try out the Tutorials
[Try out](https://docs.wso2.com/display/KA100/Tutorials) the KA real-life business use cases.

## Deep dive into WSO2 KA
To know more about WSO2 KA please see our [documentation] (https://docs.wso2.com/display/KA100/WSO2+Kubernetes+Artifacts)
