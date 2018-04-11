# Hazelcast OpenShift

This repository contains the following folders:

* [Hazelcast Enterprise OpenShift Centos](hazelcast-enterprise-openshift-centos/): Hazelcast Enterprise Docker image dedicated to the OpenShift platform; _this image is based on Centos_
* [Hazelcast Enterprise OpenShift RHEL](hazelcast-enterprise-openshift-rhel/): Hazelcast Enterprise Docker image dedicated to be published in [Red Hat Container Catalog](https://access.redhat.com/containers/); _this image is based on RHEL and as such you need to build it from the OpsnShift Docker Engine._
* [Hazelcast OpenShift Origin](hazelcast-openshift-origin/): Hazelcast Docker image dedicated to the OpenShift platform; _this image is based on Centos_

# Quick Start

You can launch Hazelcast by running the following command (please check available versions for $HZ_VERSION on [Docker Store](https://store.docker.com/community/images/hazelcast/hazelcast-openshift/tags)):

```
$ oc new-app hazelcast/hazelcast-openshift:${HZ_VERSION} \
  -e HAZELCAST_KUBERNETES_SERVICE_DNS=hazelcast-openshift.$(oc project -q).svc
```

For Hazelcast Enterprise Centos, use:

```
$ oc new-app hazelcast/hazelcast-enterprise-openshift-centos:${HZ_VERSION} \
  -e HAZELCAST_KUBERNETES_SERVICE_DNS=hazelcast-enterprise-openshift-centos.$(oc project -q).svc \
  -e HZ_LICENSE_KEY=<hazelcast_enterprise_license>
```

# Complete Example

For the complete example of using Hazelcast OpenShift image in a cluster, please see [Hazelcast Code Samples](https://github.com/hazelcast/hazelcast-code-samples/tree/master/hazelcast-integration/openshift).