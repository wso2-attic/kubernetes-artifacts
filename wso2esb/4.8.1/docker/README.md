# WSO2 ESB 4.8.1 Dockerfile

WSO2 ESB 4.8.1 Dockerfile defines required resources for building a Docker image with WSO2 ESB 4.8.1.

## How to build

(1) Copy ESB 4.8.1 binary pack to the packages folder:

* [wso2esb-4.8.1.zip](http://wso2.com/products/enterprise-service-bus/)

(2) Copy kubernetes membership scheme to the artifacts/repository/components/lib folder.


(3) Run build.sh file to build the docker image: 
````
sh build.sh [docker-image-version]
````

(5) Save docker image to a local folder:
````
sh save.sh [docker-image-version]
````

