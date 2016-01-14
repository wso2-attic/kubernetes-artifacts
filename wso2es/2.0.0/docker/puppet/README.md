# WSO2 ESB Puppet Module for building Docker Image

Copy WSO2 base puppet module, ESB puppet module and Hiera configuration files to this folder as follows:

```
    ├── hiera.yaml
    ├── hieradata
    │   └── dev
    │       ├── common.yaml
    │       └── wso2
    │           ├── common.yaml
    │           └── wso2esb
    ├── manifests
    │   └── site.pp
    └── modules
        ├── wso2base
        │   ├── files
        │   │   └── jdk-7u80-linux-x64.tar.gz
        │   ├── manifests
        │   │   ├── clean.pp
        │   │   ├── configure.pp
        │   │   ├── deploy.pp
        │   │   ├── init.pp
        │   │   ├── install.pp
        │   │   ├── java.pp
        │   │   ├── patch.pp
        │   │   ├── push_files.pp
        │   │   ├── push_templates.pp
        │   │   ├── server.pp
        │   │   └── system.pp
        │   └── templates
        │       ├── hosts.erb
        │       └── wso2service.erb
        └── wso2esb
            ├── files
            │   ├── configs
            │   ├── patches
            │   └── wso2esb-4.9.0.zip
            ├── manifests
            │   └── init.pp
            └── templates
                └── 4.9.0
```

### Note
Above files have been checked into git until puppet_modules repository get updated with the following changes:
- Stop creating a system service for wso2 server for Docker
- Stop using cron in system.pp for ntpdate for Docker