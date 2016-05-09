#!/bin/sh



sed -i "s|#org.ops4j.pax.url.mvn.localRepository=|org.ops4j.pax.url.mvn.localRepository=~/.m2/repository|" /opt/karaf/etc/org.ops4j.pax.url.mvn.cfg
#sed -i "s|# org.ops4j.pax.url.mvn.proxySupport=false|org.ops4j.pax.url.mvn.proxySupport=false|" /opt/karaf/etc/org.ops4j.pax.url.mvn.cfg



/opt/karaf/bin/start



status=`/opt/karaf/bin/instance status root`
st=`echo -n "$status" | grep  "Started"`

while [ -z "$st" ]
do
    echo "Karaf not running yet"
    sleep  5
    status=`/opt/karaf/bin/instance status root`
    st=`echo -n "$status" | grep  "Started"`
done
echo "Karaf is running"


/fcrepo_config/fedora_camel_toolbox.sh

cd /usr/local/tomcat
sh /usr/local/tomcat/bin/catalina.sh run
