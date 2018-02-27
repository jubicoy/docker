FROM jenkins/jenkins:lts as parent

FROM openjdk:8-jdk

MAINTAINER Vilppu Vuorinen "vilppu.vuorinen@jubic.fi"

RUN apt-get update \
  && apt-get install -y \
    curl \
    gettext \
    gnupg \
    git \
    libnss-wrapper \
    zip \
  && rm -rf /var/lib/apt/lists/*

ENV USER_NAME jenkins
ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_SLAVE_AGENT_PORT 50000
ENV JENKINS_UC https://updates.jenkins.io
ENV JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental
ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

COPY --from=parent /sbin/tini /sbin/tini
COPY --from=parent /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy
COPY --from=parent /usr/share/jenkins/jenkins.war /usr/share/jenkins/jenkins.war

# from a derived Dockerfile, can use `RUN plugins.sh active.txt` to setup /usr/share/jenkins/ref/plugins from a support bundle
COPY --from=parent /usr/local/bin/jenkins-support /usr/local/bin/jenkins-support
COPY --from=parent /usr/local/bin/jenkins.sh /usr/local/bin/jenkins.sh
COPY --from=parent /usr/local/bin/plugins.sh /usr/local/bin/plugins.sh
COPY --from=parent /usr/local/bin/install-plugins.sh /usr/local/bin/install-plugins.sh

COPY root /

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades. Permissions are fixed.
RUN mkdir -p "${JENKINS_HOME}" \
  && /usr/libexec/fix-permissions "${JENKINS_HOME}" \
  && mkdir -p /opt/jenkins \
  && /usr/libexec/fix-permissions /opt/jenkins
VOLUME /var/jenkins_home

# for main web interface:
EXPOSE 8080

# will be used by attached slave agents:
EXPOSE 50000

RUN cat /opt/nss.sh >> /etc/bash.bashrc

ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["/usr/local/bin/jenkins.sh"]
