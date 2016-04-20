FROM tomcat:8.5


MAINTAINER  Jörg Panzer, SUB


ENV JRE_HOME         /usr

ENV FEDORA_VERSION 4.4.0
ENV FEDORA_TAG 4.4.0

# 999(docker)
ENV FCREPO_USER docker
ENV FCREPO_UID 1000

ENV KARAF_VERSION 4.0.1

ENV MAVEN_OPTS  "-Xmx1024m" -XX:MaxMetaspaceSize=1024m"
ENV MAVEN_VERSION 3.3.9
ENV MAVEN_HOME /usr/share/maven
ENV PATH "$PATH:$MAVEN_HOME/bin"

# Install Tomcat 7.
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH


# ---------------------
#

RUN apt-get update && \
    apt-get -y install --no-install-recommends  git  curl


#RUN groupadd -r $FCREPO_USER && \
#  useradd -r -u $FCREPO_UID  $FCREPO_USER


RUN sed -i '$i<role rolename="fedoraUser"/>$i<role rolename="fedoraAdmin"/>$i<role rolename="manager-gui"/>$i<user username="testuser" password="password1" roles="fedoraUser"/>$i<user username="adminuser" password="password2" roles="fedoraUser"/>$i<user username="fedoraAdmin" password="fedoraAdmin" roles="fedoraAdmin"/>$i<user username="fedora4" password="fedora4" roles="manager-gui"/>'  $CATALINA_HOME/conf/tomcat-users.xml

# todo ensure tomcat/fedora is not running under root


#--------------
# install maven


RUN curl -fsSL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
    && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
    && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn



#----------------
# Install Fedora4

WORKDIR /tmp
RUN curl -fSL https://github.com/fcrepo4/fcrepo4/releases/download/fcrepo-$FEDORA_TAG/fcrepo-webapp-$FEDORA_VERSION.war -o fcrepo.war
RUN mkdir -p /var/lib/tomcat/fcrepo4-data
	#&& chown -hR $FCREPO_UID /var/lib/tomcat/fcrepo4-data \
	#&& chmod g-w /var/lib/tomcat/fcrepo4-data \

RUN cp fcrepo.war /usr/local/tomcat/webapps/fcrepo.war
#   && chown -hR $FCREPO_UID /usr/local/tomcat/webapps/fcrepo.war


#---------------------
# Install Apache Karaf   (see: https://hub.docker.com/r/yinlinchen/fcrepo4-docker/)


#RUN cd /tmp \
#	&& curl -fSL http://mirror.csclub.uwaterloo.ca/apache/karaf/$KARAF_VERSION/apache-karaf-$KARAF_VERSION.tar.gz -o apache-karaf-$KARAF_VERSION.tar.gz \
#	&& tar -xzf apache-karaf-$KARAF_VERSION.tar.gz \
#	&& mv /tmp/apache-karaf-$KARAF_VERSION /opt \
#	&& ln -s /opt/apache-karaf-$KARAF_VERSION /opt/karaf \
#	&& rm apache-karaf-$KARAF_VERSION.tar.gz*


#---------------------
# Fedora Camel Toolbox
#COPY scripts/fedora_camel_toolbox.script /fcrepo_config/
#COPY scripts/fedora_camel_toolbox.sh /fcrepo_config/
#COPY scripts/runall.sh /fcrepo_config/

#-----------------------
# build and add features
#RUN cd /usr/local/tomcat \
#    && chown -R $FCREPO_UID bin webapps temp logs work conf \
#    && chmod -R 750 bin webapps temp logs work conf



#RUN chown -R $FCREPO_UID /opt/karaf \
#    && chmod -R 750 /opt/karaf/etc \
#    && chown -R $FCREPO_UID /opt/apache-karaf-$KARAF_VERSION \
#    && chmod -R 750 /opt/apache-karaf-$KARAF_VERSION/etc



#------------
# start tomcat

WORKDIR $CATALINA_HOME
USER $FCREPO_UID
#CMD [ "sh", "/fcrepo_config/runall.sh"]

CMD ["/usr/local/tomcat/bin/catalina.sh", "run"]
