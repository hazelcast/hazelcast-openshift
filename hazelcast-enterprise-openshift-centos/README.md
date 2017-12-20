
This repository includes a default configuration file, a template and the Docker file to deploy
a Hazelcast Enterprise based standalone infrastructure as a
Centos 7 based image.

- [Introduction](#introduction)
- [Deploying](#deploying)
- [Labels](#labels)
- [Security Implications](#security-implications)



# Introduction

This image simplifies the deployment of a Hazelcast Enterprise based standalone infrastructure, as a
Centos 7 based image.

This package consists of the following parts:

* Hazelcast Enterprise and related dependencies
* Centos 7
* OpenJDK 8
* Health and liveness scripts
* Start and stop scripts


_Please note that the Docker image of this distribution is based on the 
[`hazelcast-enterprise-kubernetes` image](https://github.com/hazelcast/hazelcast-docker)._

# Deploying

## Prerequisites

1) Up and Running OpenShift Container Platform (OCP) version 3.4 or 3.5 that you can login as `system:admin`.

  * You may install OpenShift Container Development Kit from [Redhat](https://developers.redhat.com/products/cdk/download/), if you need to test on your local machine. Please note that
downloading and installing will require Redhat subscription. Moreover, please follow the CDK installation
[document](https://access.redhat.com/documentation/en-us/red_hat_container_development_kit/2.4/html/installation_guide/).
After installation of the CDK, you will need to have an up and running OpenShift Container Platform virtual machine.

2) Another important note would be that this document assumes familiarity with `oc` CLI, OCP and Docker.

## Starting Hazelcast Enterprise Cluster

Before starting to deploy your Hazelcast Enterprise cluster, make sure that you have a valid license key for Hazelcast Enterprise version. You can get a trial key from [this link](https://hazelcast.com/hazelcast-enterprise-download/trial/).

### Creating Volume and Loading Custom Configurations

This is a **prerequisite** step for the next section if you have custom configurations or JARs.

Moreover, OCP 3.5 installations on cloud providers like AWS may not contain `Persistent Volumes`(PV). In that case, you first must create a PV to deploy Hazelcast Enterprise cluster with `hazelcast-template.json` .

In order to share custom configurations or custom domain JARs (for example `EntryProcessor` implementations) between Hazelcast Enterprise Pods, you need to add a persistent volume in OCP. In `hazelcast-template.json` this directory is named as `/data/hazelcast`, and it should be claimed. Below, you can find how to add a persistent volume in OCP. Please notice that it is just an example of a persistent volume creation with `NFS`; there are many different ways that you can map volumes in Kubernetes and OpenShift Platform. You can find the available volumes via [this link](https://docs.openshift.com/container-platform/3.4/rest_api/kubernetes_v1.html#v1-volume)

* Login to your OCP console using the command `oc login <your-ocp-url>` with `system:admin` user or rights.
* Create a directory in master for the physical storage as shown below:

```
mkdir -p <your-pv-path>
chmod -R 777 <parent-path-to-pv> [may require root permissions]
# Add to /etc/exports
<your-pv-path> *(rw,root_squash)
# Enable the new exports without bouncing the NFS service
exportfs -a
```

`NFS` Security provisioning may be required, therefore you may need to add `nfsnobody` user and group to `<parent-path-to-pv>`. Please refer to [this link](https://docs.openshift.com/container-platform/3.4/install_config/persistent_storage/persistent_storage_nfs.html#install-config-persistent-storage-persistent-storage-nfs) for details.

* Open a text editor and add the following deployment YAML for persistent volume:

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: <your-pv-name>
spec:
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    server: localhost
    path: <your-pv-path>
```

Save this file. Please also notice that `Reclaim Policy` is set as `Retain`. Therefore, contents of this folder will remain as is, between successive `claims`.

`your-pv-name` is important and you need to input this name to `HAZELCAST_VOLUME_NAME` during deployments with `hazelcast-template.json`.

* Run `oc create -f <your-pv-yaml>` which will create a `PersistentVolume`.
* Run `oc get pv` to verify, and you should see `STATUS` as `AVAILABLE`.
* Go to `<your-pv-path>` and copy your custom Hazelcast configuration as `hazelcast.xml`. You may also copy or transfer `custom jars` to this directory. Make sure that your custom configuration file is named as  `hazelcast.xml`. You may use `scp` or `sftp` to transfer these files.

If you need to redeploy Hazelcast Enterprise cluster with `hazelcast-template.json`, first you may need to remove the logical persistent volume bindings, since their creation policy is `RETAIN`. In order to delete or tear down, please run the following commands:

* `oc delete pvc hz-vc` (hz-vc is the claim name from Kubernetes template, you do not need to change its name)
* `oc delete pv <your-pv-name>`
* `oc create -f <your-pv-yaml>`

Please note that contents of your previous deployment is preserved. If you change the claim policy to `RECYCLE`, you have to transfer all custom files to `<your-pv-path>` before each successive deployments.

### Deploying on Web Console

* In the web browser, navigate to your OCP console page and login.

* Create a project with `your-project-name`:

  ![create](../assets/create-new-project.png)

* In the following steps we will use `kubernetes-template.json` to pull the image, which is under Hazelcast Dockerhub repo, for creating cluster with Replication configuration.

* Click `Add to Project` and then `Import YAML/JSON` to start deploying Hazelcast cluster on OCP.

* Copy and paste the contents of `kubernetes-template.json` onto the editor, or browse and upload it.

  * Please note that default image is `hazelcast/hazelcast-enterprise-openshift-centos:3.8.6`.
  * This template file provides sample deployment, you can change freely.
  * Please note that added `readiness` probe, which checks whether the cluster is in a safe state. Safe state means; there are no partitions being migrated and all backups are in sync when this probe is called. If it is not suitable for you please remove it.

* This template file contains all the deployment information to setup a Hazelcast Enterprise cluster inside OCP. It configures the necessary `ReplicationController`, health checks and image to use. It also offers a set of properties to be requested when creating a new cluster (such as `clustername`).

* Fill out the `Configuration Properties` section.

* `NAMESPACE` value is important and should match with your project namespace.

* Enter your Hazelcast Enterprise license key to `ENTERPRISE_LICENSE_KEY` input section.

* Now it is ready to go.

    ![over](../assets/over.png)

# Labels


Following labels are set for this image:

- `name=` : Registry location and name of the image.

- `version=` : Centos version from which the container was built.

- `release=` : Hazelcast Enterprise release version built into this image.

# Security Implications

This image exposes port 5701 as the external port for cluster communication (member to member) and between Hazelcast Enterprise clients and cluster (client-server).

The port is reachable from the OpenShift environment only and is not registered for public reachability.
