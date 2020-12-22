FROM registry.access.redhat.com/ubi8/ubi
MAINTAINER Hazelcast, Inc. Integration Team <info@hazelcast.com>

# Versions of Hazelcast and Hazelcast plugins
ARG HZ_VERSION=4.1.1
ARG CACHE_API_VERSION=1.1.1
ARG JMX_PROMETHEUS_AGENT_VERSION=0.11.0
ARG NETTY_VERSION=4.1.47.Final
ARG NETTY_TCNATIVE_VERSION=2.0.29.Final
ARG LOG4J2_VERSION=2.13.3

# Build constants
ARG HZ_HOME="/opt/hazelcast"

# JARs to download
ARG HAZELCAST_ALL_URL="https://repository.hazelcast.com/release/com/hazelcast/hazelcast-enterprise-all/${HZ_VERSION}/hazelcast-enterprise-all-${HZ_VERSION}.jar"
ARG CACHE_API_URL="https://repo1.maven.org/maven2/javax/cache/cache-api/${CACHE_API_VERSION}/cache-api-${CACHE_API_VERSION}.jar"
ARG PROMETHEUS_AGENT_URL="https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${JMX_PROMETHEUS_AGENT_VERSION}/jmx_prometheus_javaagent-${JMX_PROMETHEUS_AGENT_VERSION}.jar"
ARG NETTY_URL="https://repo1.maven.org/maven2/io/netty/netty-all/${NETTY_VERSION}/netty-all-${NETTY_VERSION}.jar"
ARG NETTY_TCNATIVE_URL="https://repo1.maven.org/maven2/io/netty/netty-tcnative-boringssl-static/${NETTY_TCNATIVE_VERSION}/netty-tcnative-boringssl-static-${NETTY_TCNATIVE_VERSION}.jar"
ARG LOG4J2_URLS="https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-core/${LOG4J2_VERSION}/log4j-core-${LOG4J2_VERSION}.jar https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-api/${LOG4J2_VERSION}/log4j-api-${LOG4J2_VERSION}.jar"

ENV HZ_HOME="${HZ_HOME}" \
    HZ_CP_MOUNT="${HZ_HOME}/external" \
    LANG="en_US.utf8" \
    USER_NAME="hazelcast" \
    USER_UID=10001 \
    CLASSPATH_DEFAULT="${HZ_HOME}/*:${HZ_HOME}/lib/*" \
    JAVA_OPTS_DEFAULT="-Djava.net.preferIPv4Stack=true -Dhazelcast.logging.type=log4j2 -Dlog4j.configurationFile=${HZ_HOME}/log4j2.properties -XX:MaxRAMPercentage=80.0 -XX:+UseParallelGC --add-modules java.se --add-exports java.base/jdk.internal.ref=ALL-UNNAMED --add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/java.nio=ALL-UNNAMED --add-opens java.base/sun.nio.ch=ALL-UNNAMED --add-opens java.management/sun.management=ALL-UNNAMED --add-opens jdk.management/com.sun.management.internal=ALL-UNNAMED" \
    HZ_LICENSE_KEY="" \
    PROMETHEUS_PORT="" \
    PROMETHEUS_CONFIG="${HZ_HOME}/jmx_agent_config.yaml" \
    LOGGING_LEVEL="" \
    CLASSPATH="" \
    JAVA_OPTS=""

LABEL name="hazelcast/hazelcast-enterprise-openshift-rhel" \
      vendor="Hazelcast, Inc." \
      version="8.1" \
      release="${HZ_VERSION}" \
      url="http://www.hazelcast.com" \
      summary="Hazelcast Openshift Image, certified to RHEL 8" \
      description="Starts a standalone Hazelcast server instance to form a cluster based on kubernetes discovery inside Openshift" \
      io.k8s.description="Starts a standalone Hazelcast server instance to form a cluster based on kubernetes discovery inside Openshift" \
      io.k8s.display-name="Hazelcast" \
      io.openshift.expose-services="5701:tcp" \
      io.openshift.tags="hazelcast,kubernetes,rhel8"

EXPOSE 5701

COPY *.sh *.yaml *.jar *.properties ${HZ_HOME}/
COPY licenses /licenses
COPY help.1 /help.1

RUN mkdir -p "${HZ_HOME}/lib" "$HZ_CP_MOUNT" \
    && echo "Disabling subscription-manager plugin to prevent redundant logs" \
    && sed -i 's/^enabled=.*/enabled=0/g' /etc/dnf/plugins/subscription-manager.conf \
    && dnf config-manager --disable \
    && dnf update -y  && rm -rf /var/cache/dnf \
    && dnf -y update-minimal --security --sec-severity=Important --sec-severity=Critical --setopt=tsflags=nodocs \
    && echo "Installing new packages" \
    && dnf -y --setopt=tsflags=nodocs install java-11-openjdk &> /dev/null \
    && dnf -y clean all \
    && echo "Downloading Hazelcast and related JARs" \
    && cd "${HZ_HOME}/lib" \
    && for JAR_URL in ${HAZELCAST_ALL_URL} ${CACHE_API_URL} ${PROMETHEUS_AGENT_URL} ${NETTY_URL} ${NETTY_TCNATIVE_URL} ${LOG4J2_URLS}; do curl -sf -O -L ${JAR_URL}; done \
    && mv jmx_prometheus_javaagent-*.jar jmx_prometheus_javaagent.jar \
    && echo "Adding non-root user" \
    && useradd -l -u $USER_UID -r -g 0 -d $HZ_HOME -s /sbin/nologin -c "${USER_UID} application user" $USER_NAME \
    && chown -R $USER_UID:0 $HZ_HOME $HZ_CP_MOUNT \
    && chmod -R g=u "$HZ_HOME" \
    && chmod -R +r $HZ_HOME

WORKDIR ${HZ_HOME}

### Switch to hazelcast user
USER ${USER_UID}

# Start Hazelcast server
CMD ["/bin/sh", "-c", "./start-hazelcast.sh"]
