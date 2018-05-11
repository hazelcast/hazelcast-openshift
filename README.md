# Hazelcast OpenShift

This repository contains the following folders:

* [Hazelcast Enterprise OpenShift](hazelcast-enterprise-openshift-centos/) (Docker Hub: [hazelcast/hazelcast-enterprise-openshift-centos](https://hub.docker.com/r/hazelcast/hazelcast-enterprise-openshift-centos/))
* [Hazelcast Enterprise OpenShift RHEL](hazelcast-enterprise-openshift-rhel/) (Red Hat Container Catalog: [registry.connect.redhat.com/hazelcast/hazelcast-3-rhel7](https://access.redhat.com/containers/?tab=overview#/registry.connect.redhat.com/hazelcast/hazelcast-3-rhel7)) _Note that this image is based on RHEL and as such you need to build it from the OpenShift Docker Engine._
* [Hazelcast OpenShift](hazelcast-openshift-origin/) (Docker Hub: [hazelcast/hazelcast-openshift](https://hub.docker.com/r/hazelcast/hazelcast-openshift/))

# Quick Start

You can launch a Hazelcast cluster by starting a headless service and multiple replicas of Hazelcast image with the environment variable `HAZELCAST_KUBERNETES_SERVICE_DNS=<service_name>.<project_name>.svc`.

Here's an example of the simplest template that could be used: `hazelcast-template.yml`.

```
apiVersion: v1
kind: Template
objects:
- apiVersion: v1
  kind: DeploymentConfig
  metadata:
    name: hazelcast
  spec:
    replicas: 3
    selector: 
      name: hazelcast
    template:
      metadata:
        labels:
          name: hazelcast
      spec:
        containers:
          - name: hazelcast
            image: hazelcast/hazelcast-openshift  
            ports:
              - containerPort: 5701
                protocol: TCP
            env:
              - name: HAZELCAST_KUBERNETES_SERVICE_DNS
                value: hazelcast-service.<project_name>.svc

- apiVersion: v1
  kind: Service
  metadata:
    name: hazelcast-service
  spec:
    type: ClusterIP
    clusterIP: None
    ports:
      - port: 5701
        protocol: TCP
    selector:
      name: hazelcast
```

Then, the following command starts the cluster:

```
oc new-app -f hazelcast-template.yml
```

In case of Hazelcast Enterprise, the `hazelcast/hazelcast-enterprise-openshift-centos` image must be used with the additional environment variable:

```
env:
  - name: HZ_LICENSE_KEY
    value: <hazelcast_license_key>
```

# Hazelcast Client

If the client application is inside the OpenShift project, then it can use `HazelcastKubernetesDiscoveryStrategy` as presented in [Complete Example](#complete-example).

If the client application is outside the OpenShift project, then the cluster needs to be exposed by the service with `externalIP` and the Hazelcast client needs to have the Smart Routing feature disabled ([example](https://github.com/hazelcast/hazelcast-code-samples/tree/master/hazelcast-integration/openshift#external-hazelcast-client)).


# Complete Example

For the complete example of using Hazelcast OpenShift image in a cluster, please see [Hazelcast Code Samples](https://github.com/hazelcast/hazelcast-code-samples/tree/master/hazelcast-integration/openshift).