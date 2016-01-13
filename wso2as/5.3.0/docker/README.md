# WSO2 AS 5.3.0 Dockerfile

WSO2 AS 5.3.0 Dockerfile defines resources for building a Docker image with WSO2 AS 5.3.0 and runtime configurations. It uses Puppet and Hiera to update the configuration.

## Building the Docker Images

WSO2 AS Docker image is configured using the Puppet modules. These modules need to be copied from the [WSO2 Puppet Modules repository](https://github.com/wso2/puppet-modules).

* Get the Puppet module distribution for WSO2 AS.
* Extract the WSO2 AS Puppet module distribution to `puppet/` folder. It will add the Puppet modules (`wso2base` and `wso2as`) and the Hiera data files to the setup. Add or modify the Hiera YAML files as needed.
* Build Kubernetes Hazelcast Membership Scheme (`common/kubernetes-membership-scheme`) and copy the resulting jar file to `puppet/modules/wso2as/files/configs/repository/components/lib` folder.
* Download and copy the JDK 1.7 and WSO2 AS 5.3.0 packs to relevant locations.
    * [jdk-7u80-linux-x64.tar.gz](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html) -> `puppet/modules/wso2base/files`
    * [wso2as-5.3.0.zip](http://wso2.com/products/application-server/) -> `puppet/modules/wso2as/files`
* Copy AS deployable artifacts to the `puppet/modules/wso2as/files/configs/repository/deployment/server` folder with required sub folder structure.
* The `puppet` folder should look like as follows.
```
├── puppet
│   ├── hieradata
│   │   └── dev
│   │       ├── common.yaml
│   │       └── wso2
│   │           ├── common.yaml
│   │           └── wso2as
│   │               └── 5.3.0
│   │                   ├── default.yaml
│   │                   ├── manager.yaml
│   │                   └── worker.yaml
│   ├── hiera.yaml
│   ├── manifests
│   │   └── site.pp
│   └── modules
│       ├── wso2as
│       │   ├── files
│       │   │   ├── configs
│       │   │   │   └── repository
│       │   │   │       └── components
│       │   │   │           ├── dropins
│       │   │   │           └── lib
│       │   │   ├── patches
│       │   │   │   └── repository
│       │   │   │       └── components
│       │   │   │           └── patches
│       │   │   └── wso2as-5.3.0.zip
│       │   ├── manifests
│       │   │   └── init.pp
│       │   └── templates
│       │       └── 5.3.0
│       │           ├── bin
│       │           │   └── wso2server.sh.erb
│       │           └── repository
│       │               └── conf
│       │                   ├── axis2
│       │                   │   └── axis2.xml.erb
│       │                   ├── carbon.xml.erb
│       │                   ├── datasources
│       │                   │   └── master-datasources.xml.erb
│       │                   ├── registry.xml.erb
│       │                   ├── tomcat
│       │                   │   └── catalina-server.xml.erb
│       │                   └── user-mgt.xml.erb
│       └── wso2base
│           ├── files
│           │   └── jdk-7u80-linux-x64.tar.gz
│           ├── manifests
│           │   ├── clean.pp
│           │   ├── configure.pp
│           │   ├── deploy.pp
│           │   ├── init.pp
│           │   ├── install.pp
│           │   ├── java.pp
│           │   ├── patch.pp
│           │   ├── push_files.pp
│           │   ├── push_templates.pp
│           │   ├── server.pp
│           │   └── system.pp
│           └── templates
│               ├── hosts.erb
│               └── wso2service.erb


```

* Build the Docker images, providing an image version (ex: `0.0.1`)
```bash
sudo ./build.sh 0.0.1
```
* The builder script will build images related to all the server profiles (`default` | `worker` | `manager`), and the following images will be listed.
```bash
$ sudo docker images
REPOSITORY               TAG                   IMAGE ID            CREATED             VIRTUAL SIZE
wso2/as-5.3.0            0.0.2                 4af024d04bb1        12 minutes ago      1.986 GB
wso2/as-worker-5.3.0     0.0.2                 56f63e2d4522        15 minutes ago      1.986 GB
wso2/as-manager-5.3.0    0.0.2                 eacc510cebdf        17 minutes ago      1.986 GB
wso2/k8s-base            1.0.0                 b9733232eb15        About an hour ago   349.3 MB

```

* Export the docker images to the local filesystem and import it to the required Docker environment (ex: Docker registry):
````
sh save.sh [docker-image-version]
scp [docker-image-filename] [docker-host]:
ssh [docker-host]
docker load [docker-image-filename]
````
