#!/bin/sh



sed -i "s|#org.ops4j.pax.url.mvn.localRepository=|org.ops4j.pax.url.mvn.localRepository=~/.m2/repository|" /opt/karaf/etc/org.ops4j.pax.url.mvn.cfg
#sed -i "s|# org.ops4j.pax.url.mvn.proxySupport=false|org.ops4j.pax.url.mvn.proxySupport=false|" /opt/karaf/etc/org.ops4j.pax.url.mvn.cfg


/opt/karaf/bin/start

sleep 90

/fcrepo_config/fedora_camel_toolbox.sh


cd /usr/local/tomcat
sh /usr/local/tomcat/bin/catalina.sh run


echo "zu weit"
sleep 600

#CMD ["/opt/tomcat/bin/catalina.sh", "run"]