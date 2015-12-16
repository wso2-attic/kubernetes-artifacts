# WSO2 ESB 4.8.1 Dockerfile

WSO2 ESB 4.8.1 Dockerfile defines resources for building a Docker image with WSO2 ESB 4.8.1 and runtime configurations. 

## How to build

(1) Copy WSO2 ESB 4.8.1 binary package and the Puppet module to the packages folder:

* [wso2esb-4.8.1.zip](http://wso2.com/products/enterprise-service-bus/)
* [wso2esb-4.8.1-puppet-module.tar.gz]

(2) Update Hiera configuration data files with environment/product/profile specific values.

(3) Copy Kubernetes membership scheme to the artifacts/repository/components/lib folder.

(4) Copy ESB artifacts to the artifacts/repository/deployment/server folder with required sub folder structure. 

(5) Run build.sh file to build the docker image. This process will set runtime configuration data using Puppet, copy kubernetes membership scheme and the ESB artifacts to the server home. Once the build process is completed Docker image will be available in the local Docker registry. 
````
sh build.sh [docker-image-version]
````

(6) Export the docker image to the local filesystem and import it to the required Docker environment:
````
sh save.sh [docker-image-version]
scp [docker-image-filename] [docker-host]:
ssh [docker-host]
docker load [docker-image-filename]
````
