#!/bin/bash


echo "---whoami --------------------------------"
whoami

echo "--- ls -l --------------------------------"
ls -l $CATALINA_HOME/conf

mv /usr/local/tomcat/tomcat-users.xml /usr/local/tomcat/conf/tomcat-users.xml


echo "--- ps aux (1) --------------------------------"
ps aux


catalina.sh run &
#catalina.sh run > /dev/null 2>&1 &
#/usr/local/tomcat/bin/catalina.sh run &

echo "--- ps aux (2)  --------------------------------"
ps aux



#----------------
# Install Fedora4



cd /tmp
curl -fSL https://github.com/fcrepo4/fcrepo4/releases/download/fcrepo-$FEDORA_TAG/fcrepo-webapp-$FEDORA_VERSION.war -o fcrepo.war
chown -R $FCREPO_USER:$FCREPO_USER fcrepo.war

#mkdir -p /var/lib/tomcat/fcrepo4-data
#RUN chown -R $FCREPO_UID /var/lib/tomcat/fcrepo4-data
#	&& chmod g-w /var/lib/tomcat/fcrepo4-data

cp fcrepo.war /usr/local/tomcat/webapps/fcrepo.war
#chown -R $FCREPO_USER:$FCREPO_USER /usr/local/tomcat/webapps/fcrepo.war

echo "--- sleep 25  --------------------------------"
sleep 25

cd $CATALINA_HOME
chown -R $FCREPO_USER:$FCREPO_USER bin webapps temp logs work conf
chmod -R 777 bin webapps temp logs work conf




#---------------------
# Fedora Camel Toolbox
#COPY scripts/fedora_camel_toolbox.script /fcrepo_config/
#COPY scripts/fedora_camel_toolbox.sh /fcrepo_config/
#COPY scripts/runall.sh /fcrepo_config/

#-----------------------
# build and add features

#RUN mkdir -p /usr/local/tomcat/conf/Catalina/localhost
#RUN chown -R $FCREPO_UID /usr/local/tomcat/conf/Catalina
#RUN chmod -R 740 /usr/local/tomcat/conf/Catalina
#RUN chmod -R +s /usr/local/tomcat/conf/Catalina

tail -f logs/catalina.*.log