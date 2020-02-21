FROM registry.access.redhat.com/ubi8/ubi
MAINTAINER Hazelcast, Inc. Integration Team <info@hazelcast.com>

ENV HZ_HOME /opt/hazelcast/
ENV HZ_CP_MOUNT ${HZ_HOME}/external
ENV LANG en_US.utf8

ENV USER_NAME=hazelcast
ENV USER_UID=10001

ENV HZ_VERSION 3.11.7

ARG HZ_MAVEN_DIR=${HZ_VERSION}
ARG REPOSITORY_URL=https://repository.hazelcast.com
ARG NETTY_VERSION=4.1.32.Final
ARG NETTY_TCNATIVE_VERSION=2.0.20.Final

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

RUN mkdir -p $HZ_HOME
RUN mkdir -p $HZ_CP_MOUNT
WORKDIR $HZ_HOME

ADD hazelcast.xml $HZ_HOME/hazelcast.xml
ADD start.sh $HZ_HOME/start.sh
ADD stop.sh $HZ_HOME/stop.sh

# Add licenses
ADD licenses /licenses

### Atomic Help File
COPY description.md /tmp/

### Disable subscription-manager plugin to prevent redundant logs
RUN sed -i 's/^enabled=.*/enabled=0/g' /etc/dnf/plugins/subscription-manager.conf

RUN dnf config-manager --disable && \
    dnf update -y  && rm -rf /var/cache/dnf && \
    dnf -y update-minimal --security --sec-severity=Important --sec-severity=Critical --setopt=tsflags=nodocs && \
### Add your package needs to this installation line
    dnf -y --setopt=tsflags=nodocs install java-1.8.0-openjdk-devel apr openssl &> /dev/null && \
### Install go-md2man to help markdown to man conversion
    dnf -y --setopt=tsflags=nodocs install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm &> /dev/null && \
    dnf -y --setopt=tsflags=nodocs install golang-github-cpuguy83-go-md2man &> /dev/null && \
    go-md2man -in /tmp/description.md -out /help.1 && \
    dnf -y remove golang-github-cpuguy83-go-md2man && \
    dnf -y clean all

### add hazelcast enterprise
ADD ${REPOSITORY_URL}/release/com/hazelcast/hazelcast-enterprise-all/${HZ_VERSION}/hazelcast-enterprise-all-${HZ_VERSION}.jar $HZ_HOME

### Adding Logging redirector
ADD https://repo1.maven.org/maven2/org/slf4j/jul-to-slf4j/1.7.12/jul-to-slf4j-1.7.12.jar $HZ_HOME

### Adding JCache
ADD https://repo1.maven.org/maven2/javax/cache/cache-api/1.0.0/cache-api-1.0.0.jar $HZ_HOME

### Adding maven wrapper, downloading Hazelcast Kubernetes discovery plugin and dependencies and cleaning up
COPY mvnw $HZ_HOME/mvnw

### Configure Hazelcast
RUN useradd -l -u $USER_UID -r -g 0 -d $HZ_HOME -s /sbin/nologin -c "${USER_UID} application user" $USER_NAME
RUN chown -R $USER_UID:0 $HZ_HOME $HZ_CP_MOUNT
RUN chmod +x $HZ_HOME/*.sh

### Switch to hazelcast user
USER $USER_UID
RUN cd mvnw && \
    chmod +x mvnw && \
    ./mvnw -f dependency-copy.xml \
    -Dnetty.version=${NETTY_VERSION} \
    -Dnetty-tcnative.version=${NETTY_TCNATIVE_VERSION} \
    dependency:copy-dependencies && \
    cd .. && \
    rm -rf $HZ_HOME/mvnw && \
    rm -rf $HZ_HOME/.m2 && \
    chmod -R +r $HZ_HOME

### Expose port
EXPOSE 5701

### Start hazelcast standalone server.
CMD ["/bin/sh", "-c", "./start.sh"]
