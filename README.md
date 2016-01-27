# WSO2 Kubernetes Artifacts

This repository contains artifacts for deploying WSO2 products on [Kubernetes] (https://kubernetes.io):

- [Carbon Kubernetes Membership Scheme](#carbon-kubernetes-membership-scheme)
- [Dockerfiles for WSO2 Products](#dockerfiles-for-wso2-products)
- [Kubernetes Artifacts](#kubernetes-artifacts)

## Carbon Kubernetes Membership Scheme ##
Kubernetes membership scheme provides features for automatically discovering WSO2 carbon server clusters on Kubernetes.

### How it works
Once a Carbon server starts it will query container IP addresses in the given cluster via Kubernetes API using the given Kubernetes services. Thereafter Hazelcast network configuration will be updated with the above IP addresses. As a result the Hazelcast instance will get connected all the other members in the cluster. In addition once a new member is added to the cluster, all the other members will get connected to the new member.

### Building from Source ###
Navigate to `<REPOSITORY_HOME>/common/kubernetes-membership-scheme/` and issue the following command.
```bash
$ mvn clean install
```

### Installation

1. Apply Carbon kernel patch0012. This includes a modification in the Carbon Core component for
allowing to add third party membership schemes.

2. Copy following JAR files to the repository/components/lib directory of the Carbon server:
  - [jackson-core-2.5.4.jar](http://mvnrepository.com/artifact/com.fasterxml.jackson.core/jackson-core/2.5.4)
  - [jackson-databind-2.5.4.jar](http://mvnrepository.com/artifact/com.fasterxml.jackson.core/jackson-databind/2.5.4)
  - [jackson-annotations-2.5.4.jar](http://mvnrepository.com/artifact/com.fasterxml.jackson.core/jackson-annotations/2.5.4)
  - [kubernetes-membership-scheme-{version}.jar](#building-from-source)

3. Update axis2.xml with the following configuration:

```xml
  # Kubernetes Master IP is assumed to be 172.17.8.101
   <clustering class="org.wso2.carbon.core.clustering.hazelcast.HazelcastClusteringAgent" enable="true">
      <parameter name="membershipSchemeClassName">org.wso2.carbon.membership.scheme.kubernetes.KubernetesMembershipScheme</parameter>
      <parameter name="membershipScheme">kubernetes</parameter>
      <!-- Kubernetes master API endpoint -->
      <parameter name="KUBERNETES_MASTER">http://172.17.8.101:8080</parameter>
      <!-- Kubernetes service(s) the carbon server belongs to, use comma separated values for specifying
           multiple values. If multiple services defined, carbon server will connect to all the members
           in all the services via Hazelcast -->
      <parameter name="KUBERNETES_SERVICES">wso2esb</parameter>
      <!-- Kubernetes namespace used -->
      <parameter name="KUBERNETES_NAMESPACE">default</parameter>
   </clustering>
```


## Dockerfiles for WSO2 Products ##
The Dockerfiles define the resources and instructions to build the Docker images with the WSO2 products and runtime configurations. This process uses Puppet and Hiera to update the configuration.

### Building the Docker Images

* Get Puppet Modules
    - The Puppet modules for WSO2 products can be found in the [WSO2 Puppet Modules repository](https://github.com/wso2/puppet-modules). You can obtain the latest release from the [releases page](https://github.com/wso2/puppet-modules/releases). After getting the `wso2-puppet-modules-<version>.zip` file, extract it and set PUPPET_HOME environment variable pointing to extracted folder. Modify the Hiera files as needed.

* Add product packs and dependencies
    - Download and copy JDK 1.7 ([jdk-7u80-linux-x64.tar.gz](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html)) pack to `<REPOSITORY_HOME>/puppet/modules/wso2base/files`
    - Download the necessary products and copy them to `<REPOSITORY_HOME>/puppet/modules/<MODULE>/files`. For example, for WSO2 AS 5.3.0 download the [product pack](http://wso2.com/products/application-server/) and copy it to `<REPOSITORY_HOME>/puppet/modules/wso2as/files`.
    - Build the [Carbon Kubernetes Membership Scheme](#carbon-kubernetes-membership-scheme) and copy the resulting jar to `<REPOSITORY_HOME>/puppet/modules/<MODULE>/files/configs/repository/components/lib` folder. Repeat this for each product as needed.
    - Copy any deployable artifacts to the modules' `files` folder. For example, for WSO2 AS, copy any deployable applications to `<REPOSITORY_HOME>/puppet/modules/wso2as/files/configs/repository/deployment/server`.

* Build the docker images
    - First build the base image by executing `build.sh` script. (ex: `<REPOSITORY_HOME>/common/docker/base-image`)
    - Navigate to the `docker` folder inside the module needed. (ex: `<REPOSITORY_HOME>/wso2as/docker`).
    - Execute `build.sh` script and provide the image version and the product profiles to be built.
        + `./build.sh 0.0.1 'default|worker|manager'`
    - This will result in Docker images being built for each product profile provided. For example, for WSO2 AS, there will be three images named `wso2/as-default-5.3.0:0.0.1`, `wso2/as-manager-5.3.0:0.0.1`, and `wso2/as-worker-5.3.0:0.0.1` for the command provided above.

## Kubernetes Artifacts ##
Kubernetes Service and Replication Controller artifacts are provided for the WSO2 products inside `<REPOSITORY_HOME>/<WSO2_PRODUCT>/kubernetes`.
