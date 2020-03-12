FROM registry.access.redhat.com/ubi8/ubi
MAINTAINER Hazelcast, Inc. Integration Team <info@hazelcast.com>

ENV HZ_HOME="/opt/hazelcast" \
    HZ_CP_MOUNT="${HZ_HOME}/external" \
    LANG="en_US.utf8" \
    USER_NAME="hazelcast" \
    USER_UID=10001

ENV HZ_VERSION 4.0

ARG NETTY_VERSION=4.1.47.Final
ARG NETTY_TCNATIVE_VERSION=2.0.29.Final
ARG JCACHE_VERSION=1.1.1
ARG SLF4J_VERSION=1.7.12

LABEL name="hazelcast/hazelcast-enterprise-openshift-rhel" \
      vendor="Hazelcast, Inc." \
      version="8.1" \
      architecture="x86_64" \
      release="${HZ_VERSION}" \
      url="http://www.hazelcast.com" \
      summary="Hazelcast Openshift Image, certified to RHEL 8" \
      description="Starts a standalone Hazelcast server instance to form a cluster based on kubernetes discovery inside Openshift" \
      io.k8s.description="Starts a standalone Hazelcast server instance to form a cluster based on kubernetes discovery inside Openshift" \
      io.k8s.display-name="Hazelcast" \
      io.openshift.expose-services="5701:tcp" \
      io.openshift.tags="hazelcast,java8,kubernetes,rhel8"

COPY *.xml *.sh $HZ_HOME/
COPY licenses $HZ_HOME/licenses
COPY mvnw $HZ_HOME/mvnw

### Atomic Help File
COPY description.md /tmp/

RUN mkdir -p "$HZ_HOME" "$HZ_CP_MOUNT" && \
### Disable subscription-manager plugin to prevent redundant logs
    sed -i 's/^enabled=.*/enabled=0/g' /etc/dnf/plugins/subscription-manager.conf && \
    dnf config-manager --disable && \
    dnf update -y  && rm -rf /var/cache/dnf && \
    dnf -y update-minimal --security --sec-severity=Important --sec-severity=Critical --setopt=tsflags=nodocs && \
### Add your package needs to this installation line
    dnf -y --setopt=tsflags=nodocs install java-1.8.0-openjdk-devel apr openssl &> /dev/null && \
### Install go-md2man to help markdown to man conversion
    dnf -y --setopt=tsflags=nodocs install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm &> /dev/null && \
    dnf -y --setopt=tsflags=nodocs install golang-github-cpuguy83-go-md2man &> /dev/null && \
    go-md2man -in /tmp/description.md -out /help.1 && \
    dnf -y remove golang-github-cpuguy83-go-md2man && \
    dnf -y clean all && \
    useradd -l -u $USER_UID -r -g 0 -d $HZ_HOME -s /sbin/nologin -c "${USER_UID} application user" $USER_NAME && \
    chown -R $USER_UID:0 $HZ_HOME $HZ_CP_MOUNT && \
    chmod -R g=u "$HZ_HOME" && \
    chmod -R +r $HZ_HOME && \
    cd "$HZ_HOME/mvnw" && \
    ./mvnw -f dependency-copy.xml \
    -Dnetty.version=${NETTY_VERSION} \
    -Dnetty-tcnative.version=${NETTY_TCNATIVE_VERSION} \
    dependency:copy-dependencies && \
    rm -rf "$HZ_HOME/mvnw" "$HZ_HOME/.m2"

WORKDIR $HZ_HOME

### Switch to hazelcast user
USER $USER_UID

### Expose port
EXPOSE 5701

### Start hazelcast standalone server.
CMD ["/bin/sh", "-c", "./start.sh"]
