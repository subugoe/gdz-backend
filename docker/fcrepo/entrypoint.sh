#!/bin/bash



mv /usr/local/tomcat/tomcat-users.xml /usr/local/tomcat/conf/tomcat-users.xml


#/usr/local/tomcat/bin/catalina.sh run > /dev/null 2>&1 &
/usr/local/tomcat/bin/catalina.sh run &

sleep 120

#----------------
# Install Fedora4

cd /tmp
curl -fSL https://github.com/fcrepo4/fcrepo4/releases/download/fcrepo-$FEDORA_TAG/fcrepo-webapp-$FEDORA_VERSION.war -o fcrepo.war

mkdir -p /var/lib/tomcat/fcrepo4-data
#RUN chown -R $FCREPO_UID /var/lib/tomcat/fcrepo4-data
#	&& chmod g-w /var/lib/tomcat/fcrepo4-data

cp fcrepo.war /usr/local/tomcat/webapps/fcrepo.war
#   && chown -R $FCREPO_UID /usr/local/tomcat/webapps/fcrepo.war



#---------------------
# Fedora Camel Toolbox
#COPY scripts/fedora_camel_toolbox.script /fcrepo_config/
#COPY scripts/fedora_camel_toolbox.sh /fcrepo_config/
#COPY scripts/runall.sh /fcrepo_config/

#-----------------------
# build and add features
cd /usr/local/tomcat
  #  && chown -R $FCREPO_UID bin webapps temp logs work conf
  #  #&& chmod -R 300 bin webapps temp logs work conf

#RUN mkdir -p /usr/local/tomcat/conf/Catalina/localhost
#RUN chown -R $FCREPO_UID /usr/local/tomcat/conf/Catalina
#RUN chmod -R 740 /usr/local/tomcat/conf/Catalina
#RUN chmod -R +s /usr/local/tomcat/conf/Catalina

yes > /dev/null