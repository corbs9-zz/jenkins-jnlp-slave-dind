FROM jenkins/inbound-agent as builder

FROM docker:dind

COPY --from=builder /usr/local/bin/jenkins-slave /usr/local/bin/jenkins-agent
COPY --from=builder /usr/share/jenkins/agent.jar /usr/share/jenkins/agent.jar

ARG user=jenkins
ARG group=jenkins
ARG uid=10000
ARG gid=10000

ARG AGENT_WORKDIR=/home/${user}/agent

USER root

ENV LANG C.UTF-8

RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk/jre
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin

ENV JAVA_VERSION 8u252
ENV JAVA_ALPINE_VERSION 8.252.09-r0

RUN apk add --no-cache \
    openjdk8-jre="$JAVA_ALPINE_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]

ENV HOME /home/${user}

COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN apk add --no-cache \
        curl \
        bash \
        git \
        git-lfs \
        openssh-client \
        openssl \
        procps \
        gcc \
        make \
        musl-dev \
        libffi-dev \
        openssl-dev \
        glib \
        python3-dev \
        curl \
        sudo \
        bash \
        py-pip \
        git \ 
        openssh \
        nodejs \
        nodejs-npm

RUN pip install --upgrade docker-compose pip \
  && addgroup -g ${gid} ${group} \
  && adduser -D -h $HOME -u ${uid} -G ${group} ${user} \
  && chmod 755 /docker-entrypoint.sh \
  && rm -rf /var/cache/apk/* \
  && chmod +x /usr/local/bin/jenkins-agent \
  && chmod 644 /usr/share/jenkins/agent.jar \
  && ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave \
  && ln -sf /usr/share/jenkins/agent.jar /usr/share/jenkins/slave.jar 

RUN mkdir -p /opt/fossa \
  && cd /tmp \
  && curl -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/fossas/fossa-cli/master/install.sh | BINDIR=/opt/fossa bash \
  && ln -s /opt/fossa/fossa /usr/local/bin/fossa \
  && chmod 644 /opt/fossa/fossa  

USER ${user}
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR}

VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}

USER root

ENTRYPOINT ["/docker-entrypoint.sh"]
