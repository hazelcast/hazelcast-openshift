ARG HZ_IMAGE_TAG=3.10.3

FROM hazelcast/hazelcast-enterprise-kubernetes:${HZ_IMAGE_TAG}
MAINTAINER Hazelcast, Inc. Integration Team <info@hazelcast.com>

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
