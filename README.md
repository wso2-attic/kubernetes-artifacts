# WSO2 Kubernetes Artifacts

This repository contains artifacts for deploying WSO2 products on [Kubernetes] (https://kubernetes.io):

- [Carbon Kubernetes Membership Scheme](#carbon-kubernetes-membership-scheme)
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
      <parameter name="KUBERNETES_SERVICES">wso2as-manager,wso2as-worker</parameter>
      <!-- Kubernetes namespace used -->
      <parameter name="KUBERNETES_NAMESPACE">default</parameter>
   </clustering>
```


## Kubernetes Artifacts ##
Kubernetes Service and Replication Controller artifacts are provided for the WSO2 products inside `<REPOSITORY_HOME>/<WSO2_PRODUCT>`. Check the README inside each product for instructions on how to deploy. 
