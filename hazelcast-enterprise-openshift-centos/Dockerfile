FROM hazelcast/hazelcast-enterprise-kubernetes:3.9
MAINTAINER Hazelcast, Inc. Integration Team <info@hazelcast.com>

ENV HZ_VERSION 3.9

LABEL name="hazelcast/hazelcast-enterprise-openshift-centos" \
      vendor="Hazelcast, Inc." \
      version="7" \
      architecture="x86_64" \
      release="${HZ_VERSION}" \
      url="http://www.hazelcast.com" \
      summary="Hazelcast Openshift Image, based on CENTOS 7" \
      description="Starts a standalone Hazelcast Enterprise server instance to form a cluster based on kubernetes discovery inside Openshift" \
      io.k8s.description="Starts a standalone Hazelcast Enterprise server instance to form a cluster based on kubernetes discovery inside Openshift" \
      io.k8s.display-name="Hazelcast Enterprise" \
      io.openshift.expose-services="5701:tcp" \
      io.openshift.tags="hazelcast,java8,kubernetes,centos7"
