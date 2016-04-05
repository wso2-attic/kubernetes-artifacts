## Kubernetes Membership Scheme

Kubernetes membership scheme provides features for automatically discovering WSO2 carbon server clusters on Kubernetes.

### How it works
Once a Carbon server starts it will query container IP addresses in the given cluster via Kubernetes API using the given Kubernetes services. Thereafter Hazelcast network configuration will be updated with the above IP addresses. As a result the Hazelcast instance will get connected all the other members in the cluster. In addition once a new member is added to the cluster, all the other members will get connected to the new member.

### Installation

1. Apply Carbon kernel patch0012. This includes a modification in the Carbon Core component for
allowing to add third party membership schemes.

2. Copy following JAR files to the repository/components/lib directory of the Carbon server:

   ```
      jackson-core-2.5.4.jar
      jackson-databind-2.5.4.jar
      jackson-annotations-2.5.4.jar
      kubernetes-membership-scheme-<version>.jar
   ```

3. Update axis2.xml with the following configuration:

   ```
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

### Clustering Parameters
1. `KUBERNETES_MASTER` - Kubernetes API endpoint, **ex:** `http://172.17.8.101:8080`
2. `KUBERNETES_MASTER_USERNAME` - Kubernetes Master username (optional), **ex:** `admin`
3. `KUBERNETES_MASTER_PASSWORD` - Kubernetes Master password (optional), **ex:** `admin`
4. `KUBERNETES_NAMESPACE` - Kubernetes Namespace in which the pods are deployed, **ex:** `default`
5. `KUBERNETES_SERVICES` - Kubernetes Services that belong in the cluster, **ex:** `wso2am-gateway`
6. `KUBERNETES_MASTER_SKIP_SSL_VERIFICATION ` - Skip SSL certificate verification of the Kubernetes API (development option), **ex:** `true`
