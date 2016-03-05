This script will build the default version of specified docker images, 
scp them to the Kubernetes nodes and deploy the Kubernetes artifacts.

Tested with the Kubernetes setup at:
https://github.com/pires/kubernetes-vagrant-coreos-cluster

Usage: 
  1. set PUPPET_HOME, KUBERNETES_NODE_USER and KUBERNETES_NODE in environment.bash
  2. add the products and version that need to be tested to the array 
     'products' as comma separated tuples.
      ex.: products=(wso2am,1.9.1 wso2is,5.0.0)
  3. run the script
