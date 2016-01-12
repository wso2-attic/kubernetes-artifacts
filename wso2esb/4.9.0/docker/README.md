# WSO2 ESB 4.9.0 Dockerfile

WSO2 ESB 4.9.0 Dockerfile defines resources for building a Docker image with WSO2 ESB 4.9.0 and runtime configurations. It uses Puppet and Hiera for updating the configuration.

## How to build

1. Download and copy WSO2 ESB Puppet module and Hiera configuration data files to puppet/ folder.

2. Download and copy JDK 1.7 and WSO2 ESB 4.9.0 binary distributions to the following folders:

    - [jdk-7u80-linux-x64.tar.gz] -> puppet/modules/wso2base/files
    - [wso2esb-4.9.0.zip](http://wso2.com/products/enterprise-service-bus/) -> puppet/modules/wso2esb/files

3. Update [Hiera configuration data files] (puppet/hieradata/) with environment/product/profile specific values.

4. Copy Kubernetes membership scheme to puppet/modules/wso2esb/files/configs/repository/components/lib folder.

5. Copy ESB artifacts to the puppet/modules/wso2esb/files/configs/repository/deployment/server folder with required sub folder structure. 

6. Run build.sh file to build the docker image. This process will set runtime configuration data using Puppet, copy kubernetes membership scheme and the ESB artifacts to the server home. Once the build process is completed Docker image will be available in the local Docker registry. 
````
sh build.sh [docker-image-version]
````

7. Export the docker image to the local filesystem and import it to the required Docker environment:
````
sh save.sh [docker-image-version]
scp [docker-image-filename] [docker-host]:
ssh [docker-host]
docker load [docker-image-filename]
````
