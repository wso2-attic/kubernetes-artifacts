# WSO2 Kubernetes Artifacts
WSO2 Kubernetes Artifacts enable you to run WSO2 products seamlessly on [Kubernetes] (https://kubernetes.io) using Docker. This repository contains artifacts (Service and Replication Controller definitions) to deploy WSO2 products on Kubernetes.

## Getting Started
To deploy a WSO2 product on Kubernetes, the following steps have to be done.
* Build relevant Docker images
* Copy the images to the Kubernetes Nodes
* Run `deploy.sh` inside the relevant product folder, which will deploy the Service and the Replication Controllers

##### 1. Build Docker Images
Dockerfiles for WSO2 products are available at [`wso2/dockerfiles`](https://github.com/wso2/dockerfiles) repository. Follow the instructions provided there and build the Docker images as needed. For clustering to work for WSO2 products, the [Kubernetes Membership Scheme](https://docs.wso2.com/display/KA100/Kubernetes+Membership+Scheme+for+WSO2+Carbon) will have to be used.

##### 2. Copy the Images to Kubernetes Nodes/Registry
Copy the required Docker images over to the Kubernetes Nodes (ex: use `docker save` to create a tarball of the required image, `scp` the tarball to each node, and use `docker load` to reload the images from the copied tarballs on the nodes). Alternatively, if a private Docker registry is used, transfer the images there.

You can make use of the `load-images.sh` helper script to transfer images to the Kubernetes nodes. It will search for any Docker images with `wso2` as a part of its name on your local machine, and ask for verification to transfer them to the Kubernetes nodes. `kubectl` has to be functioning on your local machine in order for the script to retrieve the list of Kubernetes nodes. You can optionally provide a search pattern if you want to override the default `wso2` string.

**`load-images.sh` Usage**
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
If you created the Docker images with custom image names, change the `spec.template.spec.containers.image` field in the relevant Replication Controller YAML definition to match the Docker image for the required product (If you did not specify a custom image name, the Replication Controller definitions do not have to be changed, since they have the default image names used by `wso2/dockerfiles` to build the Docker images). Afterward, run `deploy.sh`. The script will deploy the Service and the Replication Controller on the Kubernetes deployment, and notify once the intended service starts running on the Pod.

> For more detailed instructions on deploying a particular WSO2 product on Kubernetes, refer to the README file in the relevant product folder.

## Kubernete Membership Scheme for Carbon
Kubernetes membership scheme provides features for automatically discovering WSO2 Carbon server clusters on Kubernetes. Refer the [documentation](https://docs.wso2.com/display/KA100/Kubernetes+Membership+Scheme+for+WSO2+Carbon) for further details on how to use it.

# Documentation
* [Introduction](https://docs.wso2.com/display/KA100/WSO2+Kubernetes+Artifacts)
* [Tutorials](https://docs.wso2.com/display/KA100/Tutorials)
