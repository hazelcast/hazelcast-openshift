# Hazelcast OpenShift

Hazelcast can be used as a Caching Layer for applications deployed to OpenShift. 

This repository provides following Docker Images for Openshift Users. You can check `Dockerfile` , and `hazelcast-template.json` for more details.

This repository contains the following folders:

* [Hazelcast Enterprise OpenShift Centos](hazelcast-enterprise-openshift-centos/): Provides the instructions and required files to deploy Hazelcast IMDG Enterprise onto OpenShift Container Platform. _This image is based on Centos_
* [Hazelcast Enterprise OpenShift RHEL](hazelcast-enterprise-openshift-rhel/): Provides the instructions and required files to deploy Hazelcast IMDG Enterprise onto OpenShift Container Platform. _This image is based on RHEL – not Centos – and as such you need to build it and register it into your Docker registry yourself._
* [Hazelcast OpenShift Origin](hazelcast-openshift-origin/): Provides the instructions and required files to deploy Hazelcast IMDG onto OpenShift.
