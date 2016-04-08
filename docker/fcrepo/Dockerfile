FROM jetty:9.3-jre8


MAINTAINER  Jörg Panzer, SUB


ENV JRE_HOME         /usr

ENV FEDORA_VERSION 4.5.0
ENV FEDORA_TAG 4.5.0

ENV FCREPO_USER docker
ENV FCREPO_UID 8080

ENV KARAF_VERSION 4.0.1



# ---------------------
#

RUN apt-get update && \
    apt-get -y install --no-install-recommends  git  curl

RUN groupadd -r $FCREPO_USER && \
  useradd -r -u $FCREPO_UID -g $FCREPO_USER $FCREPO_USER



# todo ensure jetty/fedora is not running under root


#----------------
# Install Fedora4

WORKDIR /tmp
RUN mkdir -p /var/lib/jetty/webapps
RUN curl -fSL https://github.com/fcrepo4/fcrepo4/releases/download/fcrepo-$FEDORA_TAG/fcrepo-webapp-$FEDORA_VERSION.war -o fcrepo.war \
	&& cp fcrepo.war /usr/local/jetty/webapps/fcrepo.war


#---------------------
# Install Apache Karaf   (see: https://hub.docker.com/r/yinlinchen/fcrepo4-docker/)


RUN cd /tmp \
	&& curl -fSL http://mirror.csclub.uwaterloo.ca/apache/karaf/$KARAF_VERSION/apache-karaf-$KARAF_VERSION.tar.gz -o apache-karaf-$KARAF_VERSION.tar.gz \
	&& tar -xzf apache-karaf-$KARAF_VERSION.tar.gz \
	&& mv /tmp/apache-karaf-$KARAF_VERSION /opt \
	&& ln -s /opt/apache-karaf-$KARAF_VERSION /opt/karaf \
	&& rm apache-karaf-$KARAF_VERSION.tar.gz*


#---------------------
# Fedora Camel Toolbox
COPY scripts/fedora_camel_toolbox.script /fcrepo_config/
COPY scripts/fedora_camel_toolbox.sh /fcrepo_config/
COPY scripts/runall.sh /fcrepo_config/



#------------
# start jetty
CMD [ "sh", "/fcrepo_config/runall.sh"]



#WORKDIR /fcrepo4/fcrepo-webapp/target/
#CMD ["mvn", "jetty:run"]
