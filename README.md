# Hazelcast OpenShift

This repository contains the source code for [Hazelcast Enterprise OpenShift RHEL](hazelcast-enterprise-openshift-rhel/) published in (Red Hat Container Catalog: [registry.connect.redhat.com/hazelcast/hazelcast-3-rhel7].

# Quick Start

You can launch a Hazelcast cluster by starting a headless service and multiple replicas of Hazelcast image with the environment variable `HAZELCAST_KUBERNETES_SERVICE_DNS=<service_name>.<project_name>.svc`.

Here's an example of the simplest template that could be used: `hazelcast.yaml`.

```
apiVersion: v1
kind: Template
objects:
- apiVersion: v1
  kind: ConfigMap
  metadata:
    name: hazelcast-configuration
  data:
    hazelcast.xml: |-
      <?xml version="1.0" encoding="UTF-8"?>
      <hazelcast xsi:schemaLocation="http://www.hazelcast.com/schema/config hazelcast-config-3.10.xsd"
                     xmlns="http://www.hazelcast.com/schema/config"
                     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <properties>
          <property name="hazelcast.discovery.enabled">true</property>
        </properties>
        <network>
          <join>
            <multicast enabled="false"/>
            <tcp-ip enabled="false" />
            <discovery-strategies>
              <discovery-strategy enabled="true" class="com.hazelcast.kubernetes.HazelcastKubernetesDiscoveryStrategy">
              </discovery-strategy>
            </discovery-strategies>
          </join>
        </network>
      </hazelcast>

- apiVersion: apps/v1
  kind: StatefulSet
  metadata:
    name: hazelcast
    labels:
      app: hazelcast
  spec:
    replicas: 3
    selector:
      matchLabels:
        app: hazelcast
    template:
      metadata:
        labels:
          app: hazelcast
      spec:
        containers:
        - name: hazelcast-openshift
          image: hazelcast/hazelcast:3.10.3
          ports:
          - name: hazelcast
            containerPort: 5701
          livenessProbe:
            httpGet:
              path: /hazelcast/health/node-state
              port: 5701
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 5
            successThreshold: 1
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /hazelcast/health/node-state
              port: 5701
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 1
            successThreshold: 1
            failureThreshold: 1
          volumeMounts:
          - name: hazelcast-storage
            mountPath: /data/hazelcast
          env:
          - name: HAZELCAST_KUBERNETES_SERVICE_DNS
            value: hazelcast-service.<project_name>.svc
          - name: JAVA_OPTS
            value: "-Dhazelcast.rest.enabled=true -Dhazelcast.config=/data/hazelcast/hazelcast.xml"
        volumes:
        - name: hazelcast-storage
          configMap:
            name: hazelcast-configuration

- apiVersion: v1
  kind: Service
  metadata:
    name: hazelcast-service
  spec:
    type: ClusterIP
    clusterIP: None
    selector:
      app: hazelcast
    ports:
    - protocol: TCP
      port: 5701
```

Then, the following command starts the cluster:

```
oc new-app -f hazelcast-template.yml
```

In case of Hazelcast Enterprise, the `hazelcast/hazelcast-enterprise` image must be used with the additional environment variable:

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