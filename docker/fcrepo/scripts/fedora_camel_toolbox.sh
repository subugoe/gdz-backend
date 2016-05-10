#!/bin/sh

######################
# Fedora Camel Toolbox
######################



/opt/karaf/bin/client -h 127.0.0.1 -v -l 4 -u karaf -h localhost -a 8101 -f "/fcrepo_config/fedora_camel_toolbox.script"




#--------------
# Solr indexing

if [ ! -f "/opt/karaf/etc/org.fcrepo.camel.indexing.solr.cfg" ]; then
   /opt/karaf/bin/client -h 127.0.0.1 -v -l 4 -u karaf -h localhost -a 8101 "feature:install fcrepo-indexing-solr"
    echo "solr indexing cfg created"
else
   echo "solr indexing cfg exists"
fi
sed -i 's|solr.baseUrl=localhost:8983/solr/collection1|solr.baseUrl=solr:8983/solr/gdz|' /opt/karaf/etc/org.fcrepo.camel.indexing.solr.cfg
sed -i 's|fcrepo.authUsername=$|fcrepo.authUsername=fedoraAdmin|' /opt/karaf/etc/org.fcrepo.camel.indexing.solr.cfg
sed -i 's|fcrepo.authPassword=$|fcrepo.authPassword=secret3|' /opt/karaf/etc/org.fcrepo.camel.indexing.solr.cfg




#---------------------
# Triplestore indexing

if [ ! -f "/opt/karaf/etc/org.fcrepo.camel.indexing.triplestore.cfg" ]; then
   /opt/karaf/bin/client -h 127.0.0.1 -v -l 4 -u karaf -h localhost -a 8101 "feature:install fcrepo-indexing-triplestore"
    echo "triplestore indexing cfg created"
else
   echo "triplestore indexing cfg exists"
fi
sed -i 's|fcrepo.authUsername=$|fcrepo.authUsername=fedoraAdmin|' /opt/karaf/etc/org.fcrepo.camel.indexing.triplestore.cfg
sed -i 's|fcrepo.authPassword=$|fcrepo.authPassword=secret3|' /opt/karaf/etc/org.fcrepo.camel.indexing.triplestore.cfg
sed -i 's|fcrepo.baseUrl=localhost:8080/fcrepo/rest|fcrepo.baseUrl=fcrepo:8080/fcrepo/rest|' /opt/karaf/etc/org.fcrepo.camel.indexing.triplestore.cfg
sed -i 's|triplestore.baseUrl=localhost:8080/fuseki/test/update|triplestore.baseUrl=fuseki:3030/fuseki|' /opt/karaf/etc/org.fcrepo.camel.indexing.triplestore.cfg   # todo possibly triplestore.baseUrl=fuseki:8080/fuseki/test/update




#--------------
# Audit service

if [ ! -f "/opt/karaf/etc/org.fcrepo.camel.audit.cfg" ]; then
   /opt/karaf/bin/client -h 127.0.0.1 -v -l 4  -u karaf -h localhost -a 8101 "feature:install fcrepo-audit-triplestore"
   echo "auditing cfg created"
else
   echo "auditing cfg exists"
fi
sed -i 's|triplestore.baseUrl=localhost:8080/fuseki/test/update|triplestore.baseUrl=fuseki:3030/fuseki|' /opt/karaf/etc/org.fcrepo.camel.audit.cfg
sed -i 's|event.baseUri=http://example.com/event|event.baseUri=http://gdz.sub.uni-goettingen.de/fedora_event|' /opt/karaf/etc/org.fcrepo.camel.audit.cfg




#---------------
# Fixity service

if [ ! -f "/opt/karaf/etc/org.fcrepo.camel.fixity.cfg" ]; then
   /opt/karaf/bin/client -h 127.0.0.1 -v -l 4 -u karaf -h localhost -a 8101 "feature:install fcrepo-fixity"
    echo "fixity service cfg created"
else
   echo "fixity service cfg exists"
fi
sed -i 's|fcrepo.authUsername=$|fcrepo.authUsername=fedoraAdmin|' /opt/karaf/etc/org.fcrepo.camel.fixity.cfg
sed -i 's|fcrepo.authPassword=$|fcrepo.authPassword=secret3|' /opt/karaf/etc/org.fcrepo.camel.fixity.cfg
sed -i 's|fcrepo.baseUrl=localhost:8080/fcrepo/rest|fcrepo.baseUrl=fcrepo:8080/fcrepo/rest|' /opt/karaf/etc/org.fcrepo.camel.fixity.cfg




#----------------------
# Serialization service

if [ ! -f "/opt/karaf/etc/org.fcrepo.camel.serialization.cfg" ]; then
   /opt/karaf/bin/client -h 127.0.0.1 -v -l 4 -u karaf -h localhost -a 8101 "feature:install fcrepo-serialization"
    echo "serialization service cfg created"
else
   echo "serialization service cfg exists"
fi
sed -i 's|fcrepo.authUsername=$|fcrepo.authUsername=fedoraAdmin|' /opt/karaf/etc/org.fcrepo.camel.serialization.cfg
sed -i 's|fcrepo.authPassword=$|fcrepo.authPassword=secret3|' /opt/karaf/etc/org.fcrepo.camel.serialization.cfg
sed -i 's|fcrepo.baseUrl=localhost:8080/fcrepo/rest|fcrepo.baseUrl=fcrepo:8080/fcrepo/rest|' /opt/karaf/etc/org.fcrepo.camel.serialization.cfg




#-------------------
# Reindexing service

if [ ! -f "/opt/karaf/etc/org.fcrepo.camel.reindexing.cfg" ]; then
   /opt/karaf/bin/client -h 127.0.0.1 -v -l 4 -u karaf -h localhost -a 8101 "feature:install fcrepo-reindexing"
    echo "reindexing service cfg created"
else
   echo "reindexing service cfg exists"
fi
sed -i 's|fcrepo.authUsername=$|fcrepo.authUsername=fedoraAdmin|' /opt/karaf/etc/org.fcrepo.camel.reindexing.cfg
sed -i 's|fcrepo.authPassword=$|fcrepo.authPassword=secret3|' /opt/karaf/etc/org.fcrepo.camel.reindexing.cfg
sed -i 's|fcrepo.baseUrl=localhost:8080/fcrepo/rest|fcrepo.baseUrl=fcrepo:8080/fcrepo/rest|' /opt/karaf/etc/org.fcrepo.camel.reindexing.cfg



