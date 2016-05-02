FROM tomcat:8.0-jre8


MAINTAINER  Jörg Panzer, SUB



ENV FEDORA_VERSION 4.5.0
ENV FEDORA_TAG 4.5.0



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


ENV JAVA_OPTS "${JAVA_OPTS} -Dfcrepo.home=/var/lib/tomcat/fcrepo4-data"
ENV JAVA_OPTS "${JAVA_OPTS} -Djava.io.tmpdir=/tmp"

#fcrepo.modeshape.configuration=<classpath:/config/repository.json | file:/path/to/repository.json>   $CATALINA_HOME/webapps/fcrepo/WEB-INF/classes/config/minimal-default/repository.json
ENV JAVA_OPTS "${JAVA_OPTS} -Dfcrepo.modeshape.configuration=config/minimal-default/repository.json"

#fcrepo.ispn.configuration=<config/infinispan.xml>    /usr/local/tomcat/webapps/fcrepo/WEB-INF/classes/config/infinispan/file/infinispan.xml
ENV JAVA_OPTS "${JAVA_OPTS} -Dfcrepo.ispn.configuration=config/infinispan/file/infinispan.xml"


# the following variables use the fcrepo.home as basepath if not set explicit
ENV JAVA_OPTS "${JAVA_OPTS} -Dcom.arjuna.ats.arjuna.common.ObjectStoreEnvironmentBean.default.objectStoreDir=/var/lib/tomcat/fcrepo4-data/com.arjuna.ats.arjuna.common.ObjectStoreEnvironmentBean.default.objectStoreDir"
ENV JAVA_OPTS "${JAVA_OPTS} -Dcom.arjuna.ats.arjuna.objectstore.objectStoreDir=/var/lib/tomcat/fcrepo4-data/com.arjuna.ats.arjuna.objectstore.objectStoreDir"
ENV JAVA_OPTS "${JAVA_OPTS} -Dfcrepo.ispn.CacheDirPath=/var/lib/tomcat/fcrepo4-data/fcrepo.ispn.cache"
ENV JAVA_OPTS "${JAVA_OPTS} -Dfcrepo.ispn.binary.CacheDirPath=/var/lib/tomcat/fcrepo4-data/fcrepo.ispn.binary.cache"
ENV JAVA_OPTS "${JAVA_OPTS} -Dfcrepo.modeshape.index.location=/var/lib/tomcat/fcrepo4-data/index"
ENV JAVA_OPTS "${JAVA_OPTS} -Dfcrepo.ispn.alternative.CacheDirPath=/var/lib/tomcat/fcrepo4-data/fcrepo.ispn.alternative.cache"
ENV JAVA_OPTS "${JAVA_OPTS} -Dfcrepo.ispn.binary.alternative.CacheDirPath=/var/lib/tomcat/fcrepo4-data/fcrepo.ispn.binary.alternative.cache"


#ENV JAVA_OPTS "${JAVA_OPTS} -Dfcrepo.ispn.repo.cache=/var/lib/tomcat/fcrepo4-data/fcrepo.ispn.repo.cache"
#ENV JAVA_OPTS "${JAVA_OPTS} -Dfcrepo.activemq.directory=/var/lib/tomcat/fcrepo4-data/fcrepo.activemq.directory"

# ---------------------
#

RUN apt-get update && \
    apt-get -y install --no-install-recommends  git  curl  vim


RUN sed -i '$i<Resources cachingAllowed="true" cacheMaxSize="100000" />'  /usr/local/tomcat/conf/context.xml



COPY scripts/tomcat-users.xml /usr/local/tomcat/conf/tomcat-users.xml



#----------------
# Install Fedora4



WORKDIR /tmp
RUN curl -fSL https://github.com/fcrepo4/fcrepo4/releases/download/fcrepo-$FEDORA_TAG/fcrepo-webapp-$FEDORA_VERSION.war -o fcrepo.war

RUN mkdir -p /var/lib/tomcat/fcrepo4-data
RUN chown -R $FCREPO_UID /var/lib/tomcat/fcrepo4-data


RUN cp fcrepo.war /usr/local/tomcat/webapps/fcrepo.war
RUN chown $FCREPO_UID /usr/local/tomcat/webapps/fcrepo.war


#---------------------
# Fedora Camel Toolbox
#COPY scripts/fedora_camel_toolbox.script /fcrepo_config/
#COPY scripts/fedora_camel_toolbox.sh /fcrepo_config/
#COPY scripts/runall.sh /fcrepo_config/

#-----------------------
# build and add features
WORKDIR /usr/local/tomcat
RUN chown -R $FCREPO_UID:$FCREPO_UID bin webapps temp logs work conf
  #  #&& chmod -R 300 bin webapps temp logs work conf


#RUN mkdir -p /usr/local/tomcat/conf/Catalina/localhost
#RUN chmod -R 777 /usr/local/tomcat/conf/Catalina

#RUN chown -R $FCREPO_UID:$FCREPO_UID /usr/local/tomcat/conf/Catalina













#--------------
# install maven


#RUN curl -fsSL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share
#RUN mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven
#RUN ln -s /usr/share/maven/bin/mvn /usr/bin/mvn





#---------------------
# Install Apache Karaf   (see: https://hub.docker.com/r/yinlinchen/fcrepo4-docker/)


#RUN cd /tmp \
#	&& curl -fSL http://mirror.csclub.uwaterloo.ca/apache/karaf/$KARAF_VERSION/apache-karaf-$KARAF_VERSION.tar.gz -o apache-karaf-$KARAF_VERSION.tar.gz \
#	&& tar -xzf apache-karaf-$KARAF_VERSION.tar.gz \
#	&& mv /tmp/apache-karaf-$KARAF_VERSION /opt \
#	&& ln -s /opt/apache-karaf-$KARAF_VERSION /opt/karaf \
#	&& rm apache-karaf-$KARAF_VERSION.tar.gz*


#RUN chown -R $FCREPO_UID:$FCREPO_UID /opt/karaf
#    && chown -R $FCREPO_UID:$FCREPO_UID /opt/apache-karaf-$KARAF_VERSION
#    && chmod -R 750 /opt/karaf/etc \
#    && chmod -R 750 /opt/apache-karaf-$KARAF_VERSION/etc





#---------------------
# Fedora Camel Toolbox
#COPY scripts/fedora_camel_toolbox.script /fcrepo_config/
#COPY scripts/fedora_camel_toolbox.sh /fcrepo_config/
#COPY scripts/runall.sh /fcrepo_config/




#------------
# start tomcat



USER $FCREPO
#USER $FCREPO_USER:$FCREPO_USER

#CMD [ "sh", "/fcrepo_config/runall.sh"]
CMD ["catalina.sh", "run"]


#COPY entrypoint.sh entrypoint.sh
#COPY scripts/tomcat-users.xml tomcat-users.xml
#ENTRYPOINT ["sh", "entrypoint.sh"]
