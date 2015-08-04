############################################################
# Dockerfile to build CentOS, Netflix ICE installed Container
# Dockerfile Reference: Jon Brouse @jonbrouse
# Based on CentOS6.6
############################################################

# Set the base image to CentOS
FROM centos:centos6

# File Author / Maintainer
MAINTAINER "Jash Lee" <s905060@gmail.com>

# Clean up yum repos to save spaces
RUN yum update -y >/dev/null

# Install epel repos
RUN rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

# Installing epel
RUN yum -y install epel-release

# Install Java && Git package
RUN yum install -y unzip wget git curl tar java-1.7.0-openjdk java-1.7.0-openjdk-devel

# Set Environment variables
ENV JAVA_HOME /usr/lib/jvm/java
ENV INSTALL_DIR /opt/ice
ENV ICE_HOME ${INSTALL_DIR}
ENV HOME_DIR /root
ENV GRAILS_VERSION 2.4.4
ENV GRAILS_HOME ${HOME_DIR}/.grails/wrapper/${GRAILS_VERSION}/grails-${GRAILS_VERSION}
ENV PATH $PATH:${HOME_DIR}/.grails/wrapper/${GRAILS_VERSION}/grails-${GRAILS_VERSION}/bin/
ENV S3_ID YourID
ENV S3_KEY YourKey

# Change work DIR
WORKDIR ${HOME_DIR}

# Install required software
RUN \
  rm -rf /var/lib/apt/lists/* && \
  mkdir -p ${INSTALL_DIR} && \
  mkdir -p .grails/wrapper/${GRAILS_VERSION} && \
  curl -o .grails/wrapper/${GRAILS_VERSION}/grails-${GRAILS_VERSION}.zip http://dist.springframework.org.s3.amazonaws.com/release/GRAILS/grails-${GRAILS_VERSION}.zip && \
  unzip .grails/wrapper/${GRAILS_VERSION}/grails-${GRAILS_VERSION}.zip -d .grails/wrapper/${GRAILS_VERSION} && \
  rm -rf .grails/wrapper/${GRAILS_VERSION}/grails-${GRAILS_VERSION}.zip

# Change work DIR
WORKDIR ${INSTALL_DIR}

# Ice setup
RUN \
  mkdir /mnt/ice_processor && \
  mkdir /mnt/ice_reader && \
  curl https://codeload.github.com/Netflix/ice/tar.gz/master | tar -zx -C /opt/ice --strip 1 && \
  grails ${JAVA_OPTS} wrapper && \
  rm grails-app/i18n/messages.properties && \
  sed -i -e '1i#!/bin/bash\' grailsw

# Setup Volume for ice.properties
VOLUME ["/opt/ice/src/java/ice.properties"]

EXPOSE 8080
CMD /opt/ice/grailsw -Djava.net.preferIPv4Stack=true -Dice.s3AccessKeyId=${S3_ID} -Dice.s3SecretKey=${S3_KEY} run-app
