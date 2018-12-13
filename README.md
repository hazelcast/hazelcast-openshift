# Hazelcast OpenShift

Hazelcast Enterprise is available on the OpenShift platform in a form of a dedicated Docker image [`registry.connect.redhat.com/hazelcast/hazelcast-3-rhel7`](https://access.redhat.com/containers/?tab=overview#/registry.connect.redhat.com/hazelcast/hazelcast-3-rhel7) published in [Red Hat Container Catalog](https://access.redhat.com/containers/).

# Quick Start

Create an OpenShift secret with the Hazelcast Enterprise License Key.

    $ oc create secret generic hz-enterprise-license --from-literal=key=LICENSE-KEY-HERE

Creates secret to allow access to Red Hat Container Catalog.

    $ oc create secret docker-registry rhcc \
       --docker-server=registry.connect.redhat.com \
       --docker-username=<red_hat_username> \
       --docker-password=<red_hat_password> \
       --docker-email=<red_hat_email>
    $ oc secrets link default rhcc --for=pull

Then, here's an example of a simple template that can be used to start a Hazelcast cluster (don't forget to replace `<project-name>` of `HAZELCAST_KUBERNETES_SERVICE_DNS` and `<image-version>` in the template).

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
        <network>
          <join>
            <multicast enabled="false"/>
            <kubernetes enabled="true" />
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
          image: registry.connect.redhat.com/hazelcast/hazelcast-3-rhel7:<image-version>
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
            initialDelaySeconds: 180
            periodSeconds: 10
            timeoutSeconds: 1
            successThreshold: 1
            failureThreshold: 1
          volumeMounts:
          - name: hazelcast-storage
            mountPath: /data/hazelcast
          env:
          - name: HAZELCAST_KUBERNETES_SERVICE_DNS
            value: hazelcast-service.<project-name>.svc.cluster.local
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

# Enabling Security

[Hazelcast Security Features](https://docs.hazelcast.org/docs/latest/manual/html-single/#security) can be used in the OpenShift environment. The most popular one is to use SSL for the communication. To enable it, you need to either mount a volume with `keystore`/`truststore` or include them into the Docker image. Then, in your Hazelcast configuration, add the following part:

```
<network>
    ...
    <ssl enabled="true">
        <factory-class-name>
            com.hazelcast.nio.ssl.BasicSSLContextFactory
        </factory-class-name>
        <properties>
            <property name="keyStore">path-to-keystore</property>
            <property name="keyStorePassword">keystore-password</property>
            <property name="trustStore">path-to-truststore</property>
            <property name="trustStorePassword">truststore-password</property>
        </properties>
    </ssl>
</network>
```

For more information, please check the [Kubernetes SSL Code Sample](https://github.com/hazelcast/hazelcast-code-samples/tree/master/hazelcast-integration/kubernetes/samples/ssl).

**Note**: *Currently, SSL Mutual Authentication does not work with `livenessProbe`/`readinessProbe` enabled.*

# Complete Example

For the complete example, please refer to [Hazelcast Code Samples](https://github.com/hazelcast/hazelcast-code-samples/tree/master/hazelcast-integration/openshift). It presents how to:
 * Set up the OpenShift environment
 * Start a Hazelcast cluster
 * Start Hazelcast Management Center
 * Use Hazelcast Client

