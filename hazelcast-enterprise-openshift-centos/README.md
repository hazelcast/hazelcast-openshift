This repository includes the Dockerfile and the default template configuration for Hazelcast Enterprise dedicated to the [OpenShift](https://www.openshift.com/) platform. 

Please note that the Docker image of this distribution is based on the [`hazelcast-enterprise-kubernetes`](https://github.com/hazelcast/hazelcast-docker/tree/master/hazelcast-enterprise-kubernetes) image.

### Table of Contents
- [Usage](#usage)
- [Getting Started](#getting-started)
- [Custom Configuration](#custom-configuration)
- [Development Tips](#development-tips)
- [Security Implications](#security-implications)

# Usage

You can start the Hazelcast application on OpenShift with the following command:

```
$ oc new-app -f hazelcast-template.json \
  -p DEPLOYMENT_NAME=<deployment_name>  \
  -p SERVICE_NAME=<service_name> \
  -p NAMESPACE=<project_name> \
  -p ENTERPRISE_LICENSE_KEY=<hazelcast_enterprise_license> \
  -p HAZELCAST_VOLUME_NAME=<persistent_volume>
```

# Getting Started

## Install OpenShift environment

[Minishift](https://www.openshift.org/minishift/) toolkit is used to help with running OpenShift locally. Use the following steps to set it up:

1) Install OpenShift Container Development Kit (CDK) as described [here](https://developers.redhat.com/products/cdk/download/)
2) Configure CDK and run a first Hello World OpenShift application as described [here](https://developers.redhat.com/products/cdk/hello-world/)
3) Make sure your `minishift` and `oc` tools are installed and ready to use

```
$ minishift version
minishift v1.11.0+d7f374a
CDK v3.3.0-1

$ oc version
oc v3.9.0-alpha.3+78ddc10
kubernetes v1.9.1+a0ce1bc657
features: Basic-Auth
```

## Start Hazelcast Cluster

In case of Hazelcast Enterprise, make sure that you have a valid license key for Hazelcast Enterprise version. You can get a trial key from [this link](https://hazelcast.com/hazelcast-enterprise-download/trial/).

**1) Setup and start Minishift**
```
$ minishift setup-cdk
$ minishift start
```

Note that the presented deployment process is done via the `oc` CLI tool, however each of the next steps can be also performed using OpenShift Web Console (accessed by `minishift console`).

**2) Create Project**
```
$ oc new-project hazelcast
```

Note that the name of the project is automatically its namespace, so you need to use `hazelcast` as the namespace name in the further steps.

**3) Start Hazelcast cluster**
```
$ oc new-app -f hazelcast-template.json \
  -l name=hazelcast-cluster-1 \
  -p DEPLOYMENT_NAME=hzdeployment  \
  -p SERVICE_NAME=hzservice \
  -p NAMESPACE=hazelcast \
  -p ENTERPRISE_LICENSE_KEY=<hazelcast_enterprise_license> \
  -p HAZELCAST_VOLUME_NAME=pv0001
```

Note that the label 'hazelcast-cluster-1', even though not mandatory, is helpful to manage all resources related to the created application.

Parameters:
* `DEPLOYMENT_NAME`: base name of the deployment unit (any string can be used)
* `SERVICE_NAME`: service name (any string can be used)
* `NAMESPACE`: must be the same as the OpenShift project's name
* `ENTERPRISE_LICENSE_KEY`: Hazelcast Enterprise License (not needed for the non-enterprise version)
* `HAZELCAST_VOLUME_NAME`: OpenShift Persistent Volume; Minishift comes with predefined Persistent Volumes (pv0001, pv0002, ..., pv0100); to create a new Persistent Volume please follow the description [here](https://developers.redhat.com/blog/2017/04/05/adding-persistent-storage-to-minishift-cdk-3-in-minutes/)

**4) Check that Hazelcast is running**

To check all created OpenShift resources, use the `oc get all` command.

```
$ oc get all
NAME             READY     STATUS    RESTARTS   AGE
po/hz-rc-5pl4f   1/1       Running   0          3m
po/hz-rc-dfz84   1/1       Running   0          3m
po/hz-rc-pjps7   1/1       Running   0          3m

NAME       DESIRED   CURRENT   READY     AGE
rc/hz-rc   3         3         3         3m

NAME            TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
svc/hzservice   ClusterIP   None         <none>        5701/TCP   3m
```

Then, to check the logs for each replica, use the following command:

```
$ oc logs po/hz-rc-5pl4f

...
Kubernetes Namespace: hazelcast
Kubernetes Service DNS: hzservice.hazelcast.svc.cluster.local
########################################
# RUN_JAVA=
# JAVA_OPTS=
# CLASSPATH=/data/hazelcast/*:/opt/hazelcast/*:/opt/hazelcast/external/*:
########################################
...
Members [3] {
        Member [172.17.0.3]:5701 - b047e291-ebd6-4edc-8b9c-d06fcb3b9965
        Member [172.17.0.4]:5701 - f5e6cf50-d83a-42c5-b152-2571a929fd12
        Member [172.17.0.2]:5701 - a50f8468-0852-45d2-966a-74301e04d45e this
}
...

```

**5) Delete Hazelcast cluster**

To delete all resources related to the cluster (Replication Controller, Service, PODs) use the following command:

```
$ oc delete all -l name=hazelcast-cluster-1
replicationcontroller "hz-rc" deleted
service "hzservice" deleted
```

You can also delete the Persistent Storage Claim by:

```
$ oc delete pvc hz-vc
```

If you don't do it, then the next time you run your application, the same storage will be re-used.

# Custom Configuration

In order to use a custom Hazelcast configuration (or custom domain JARs), you need to copy them into the Persistent Volume used in the application. Since the Persistent Volume is located inside the Minishift VM, you can do it using the following command:

```
$ scp -i $HOME/.minishift/machines/minishift/id_rsa hazelcast.xml docker@$(minishift ip):/mnt/sda1/var/lib/minishift/openshift.local.pv/pv0001/
```

Short explanation of the command above:
* `$HOME/.minishift/machines/minishift/id_rsa` - ssh key to Minishift VM is stored in the Minishift's home directory
* `hazelcast.xml` - custom configuration of Hazelcast
* `minishift ip` - command to return the IP address of the Minishift VM
* `/mnt/sda1/var/lib/minishift/openshift.local.pv/pv0001/` - location of the Persistent Volume `pv0001` in Minishift VM

The other possibility to put a configuration inside the Minishift VM is to share a directory with the host system using [Minishift hostfolder](https://docs.openshift.org/latest/minishift/using/host-folders.html).

After starting the application again, the containers use the custom Hazelcast configuration.

# Development Tips

## Useful commands

The complete guide to the `oc` CLI tool can be found [here](https://docs.openshift.org/latest/cli_reference/index.html). Below you can see the most interesting use cases in the context of Hazelcast.

**Scaling application**

To scale the Hazelcast application, you can change the number of replicas in the Replication Controller. For example, to scale up to 5 replicas, use the following comamnd:

```
$ oc scale rc/hz-rc --replicas=5
```

**Exposing application**

By default (as mentioned in [Security Implications](#security-implications)) the Hazelcast cluster is accessible only from the OpenShift environment. You can, however, make it accessible from outside.

```
$ oc expose svc/hzservice
route "hzservice" exposed
```

Then, you should be able to access Hazelcast via the exposed route (you can check what the route is by `oc status` or `oc get routes/hzservice`). For example, to check the health of Hazelcast:

```
$ curl hzservice-hazelcast.192.168.1.113.nip.io/hazelcast/health
Hazelcast::NodeState=ACTIVE
Hazelcast::ClusterState=ACTIVE
Hazelcast::ClusterSafe=TRUE
Hazelcast::MigrationQueueSize=0
Hazelcast::ClusterSize=1
```

## Local Docker images

During the development process, a very common use case is to build locally own Docker images and run them on Minishift. E.g. you may want to build on top of the Hazelcast OpenShift image and check if it works, or you may want to create a seprate application and check how it interacts with Hazelcast when deployed together on OpenShift.

Minishift is provided together with Docker Engine and Docker Registry. 

**1) Configure access to Docker Engine**

```
$ minishift docker-env
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.99.101:2376"
export DOCKER_CERT_PATH="/home/rafal/.minishift/certs"
export DOCKER_API_VERSION="1.24"
# Run this command to configure your shell:
# eval $(minishift docker-env)
```

**2) Push into Minishift Docker Registry**

The following commands push the image into Minishift Docker Registry. More details can be found [here](https://docs.openshift.org/latest/minishift/openshift/openshift-docker-registry.html).

```
$ docker login -u developer -p $(oc whoami -t) $(minishift openshift registry)
$ docker tag my-app $(minishift openshift registry)/myproject/my-app
$ docker push $(minishift openshift registry)/myproject/my-app
```

Then the application can be started on the OpenShift cluster with:
```
$ oc new-app --image-stream=my-app --name=my-app
```

## Debugging

Debbuging containerized applications in the OpenShift cluster can be difficult. In order to attach to the running POD, you can use the following command:

```
oc exec -ti <pod_name> -- bash
```

# Security Implications

This image exposes port 5701 as the external port for cluster communication (member to member) and between Hazelcast Enterprise clients and cluster (client-server).

The port is reachable from the OpenShift environment only and is not registered for public reachability.
