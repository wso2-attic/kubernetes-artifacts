# WSO2 ESB 4.8.1 Dockerfile

WSO2 ESB 4.8.1 Dockerfile defines required resources for building a Docker image with WSO2 ESB 4.8.1.

## How to build

(1) Copy ESB 4.8.1 binary pack and the template module to the packages folder:

* [wso2esb-4.8.1.zip](http://wso2.com/products/enterprise-service-bus/)
* [wso2esb-4.8.1-template-module] (https://github.com/wso2/private-paas-cartridges/blob/master/wso2esb/4.8.1/template-module)

(2) Build kubernetes membership scheme and copy JAR files to the template module:
```
git clone https://github.com/imesh/carbon-membership-schemes.git
cd carbon-membership-schemes/kubernetes/kubernetes-mscheme-carbon42
mvn clean install
cd target/
unzip kubernetes-mscheme-carbon42-<version>.zip
unzip <esb-template-module>
pushd kubernetes-mscheme-carbon42-<version>/lib
cp *.jar <esb-template-module>/files/repository/componentes/lib
zip <esb-template-module>
```

(4) Run build.sh file to build the docker image: 
```
sh build.sh
```

(5) Save docker image to a local folder:
```
sh save.sh
```

