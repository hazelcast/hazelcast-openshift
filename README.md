# Hazelcast OpenShift

Hazelcast can be run inside OpenShift benefiting from its cluster management software Kubernetes for discovery of members. This repository provides explanations on how you can run Hazelcast in OpenShift and provides Hazelcast Docker images (`Dockerfile`s), templates (`hazelcast-template.json`) and default configuration files (`hazelcast.xml`) for that purpose.

This repository contains the following folders:

* [Hazelcast OpenShift Origin](hazelcast-openshift-origin/): Provides the instructions and required files to deploy Hazelcast IMDG onto OpenShift.
* [Hazelcast Enterprise OpenShift](hazelcast-enterprise-openshift-centos/): Provides the instructions and required files to deploy Hazelcast IMDG Enterprise onto OpenShift Container Platform.
* [Hazelcast Enterprise OpenShift RHEL](hazelcast-enterprise-openshift-rhel/): Provides the instructions and required files to deploy Hazelcast IMDG Enterprise onto OpenShift Container Platform. _This image is based on RHEL – not Centos – and as such you need to build it and register it into your Docker registry yourself._
