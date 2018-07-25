# Hazelcast OpenShift

Hazelcast Enterprise is available on the OpenShift platform in a form of a dedicated Docker image [`registry.connect.redhat.com/hazelcast/hazelcast-3-rhel7`](https://access.redhat.com/containers/?tab=overview#/registry.connect.redhat.com/hazelcast/hazelcast-3-rhel7) published in [Red Hat Container Catalog](https://access.redhat.com/containers/).

# Quick Start

Create an OpenShift secret with the Hazelcast Enterprise License Key.

    $ oc create secret generic hz-enterprise-license --from-literal=key=LICENSE-KEY-HERE

Then, here's an example of a simple template that can be used to start a Hazelcast cluster (don't forget to fill the `<project_name>`).

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
          image: registry.connect.redhat.com/hazelcast/hazelcast-3-rhel7
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
          - name: HZ_LICENSE_KEY
            valueFrom:
              secretKeyRef:
                name: hz-enterprise-license
                key: key
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

If you save it as  `hazelcast.yaml`, then use the following command to start the cluster.

    $ oc new-app -f hazelcast.yaml

# Complete Example

For the complete example of how to set up the OpenShift environment, use Hazelcast OpenShift together with Hazelcast Management Center, and use Hazelcast Client, please refer to [Hazelcast Code Samples](https://github.com/hazelcast/hazelcast-code-samples/tree/master/hazelcast-integration/openshift).
