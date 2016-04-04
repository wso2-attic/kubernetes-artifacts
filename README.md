# WSO2 Kubernetes Artifacts
WSO2 Kubernetes Artifacts enables you to run WSO2 products seamlessly on [Kubernetes] (https://kubernetes.io) using Docker. This repository contains artifacts (Service and Replication Controller definitions) to deploy WSO2 products on Kubernetes.

## Getting Started
To deploy a WSO2 product on Kubernetes, the following overall steps have to be done.
* Build Docker images
* Copy the images to the Kubernetes Nodes
* Run `deploy.sh` inside the relevant product folder, which will deploy the Service and the Replication Controllers

##### 1. Build Docker Images
Dockerfiles for WSO2 products are available at [`wso2/dockerfiles`](https://github.com/wso2/dockerfiles) repository. Follow the instructions provided there and build the Docker images as needed.

##### 2. Copy the Images to Kubernetes Nodes/Registry
Copy the required Docker images over to the Kubernetes Nodes (ex: use `docker save` to create a tarball of the required image, `scp` the tarball to each node, and use `docker load` to reload the images from the copied tarballs on the nodes). Alternatively, if a private Docker registry is used, transfer the images there.

##### 3. Deploy Kubernetes Artifacts
Change the `spec.template.spec.containers.image` field in the relevant Replication Controller `yaml` definition to match the Docker image for the required product. Afterwards, run `deploy.sh` that will deploy the Service and the Replication Controller on the Kubernetes deployment.

> For more detailed instructions on deploying a particular WSO2 product on Kubernetes refer to README file in the relevant product folder.

# Documentation
* [Introduction](https://docs.wso2.com/display/KA100/WSO2+Kubernetes+Artifacts)
* [Tutorials](https://docs.wso2.com/display/KA100/Tutorials)
