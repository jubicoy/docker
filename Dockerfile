FROM jenkins/jenkins:lts as parent

FROM openjdk:8-jdk

MAINTAINER Vilppu Vuorinen "vilppu.vuorinen@jubic.fi"

ADD ./apt/unstable.pref /etc/apt/preferences.d/unstanble.pref
ADD ./apt/unstable.list /etc/apt/sources.list.d/unstanble.list

RUN apt-get update \
  && apt-get install -y \
    gnupg \
    git \
    curl \
    zip \
    gettext \
  && apt-get install -y -t unstable libnss-wrapper \
  && rm -rf /var/lib/apt/lists/*

ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_SLAVE_AGENT_PORT 50000

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades. Permissions are fixed.
ADD root /
RUN mkdir -p "${JENKINS_HOME}" \
  && /usr/libexec/fix-permissions "${JENKINS_HOME}" \
  && mkdir -p /opt/jenkins \
  && /usr/libexec/fix-permissions /opt/jenkins \
  && rm /usr/libexec/fix-permissions
VOLUME /var/jenkins_home

COPY --from=parent /sbin/tini /sbin/tini
COPY --from=parent /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy
COPY --from=parent /usr/share/jenkins/jenkins.war /usr/share/jenkins/jenkins.war

# for main web interface:
EXPOSE 8080

# will be used by attached slave agents:
EXPOSE 50000

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

COPY --from=parent /usr/local/bin/jenkins-support /usr/local/bin/jenkins-support
ADD passwd.template /opt/jenkins/passwd.template
COPY jenkins.sh /usr/local/bin/jenkins.sh
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]

# from a derived Dockerfile, can use `RUN plugins.sh active.txt` to setup /usr/share/jenkins/ref/plugins from a support bundle
COPY --from=parent /usr/local/bin/plugins.sh /usr/local/bin/plugins.sh
COPY --from=parent /usr/local/bin/install-plugins.sh /usr/local/bin/install-plugins.sh
