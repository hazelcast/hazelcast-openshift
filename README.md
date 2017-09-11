# Hazelcast OpenShift

Hazelcast can be run inside OpenShift benefiting from its cluster management software Kubernetes for discovery of members. This repository provides explanations on how you can run Hazelcast in OpenShift and provides Hazelcast Docker images (`Dockerfile`s), templates (`hazelcast-template.js`) and default configuration files (`hazelcast.xml`) for that purpose.

This repository contains the following folders:

* [OpenShift-Origin](hazelcast-openshift-origin/): Provides the instructions and required files to deploy Hazelcast IMDG onto OpenShift.
* [OpenShift-RHEL](hazelcast-openshift-rhel/): Provides the instructions and required files to deploy Hazelcast IMDG Enterprise onto OpenShift Container Platform.
