## README ##

### without docker ###
* start fedora
    * for test via: fcrepo_wrapper -p 8984
    * delet the fedora data dir and solr index, and restarts fedora (if the konfiguration is already running): ./cleanup.sh
* start solr
    * for test via: solr_wrapper -d solr/config/ --collection_name hydra-development
* start redis
    * for test via: docker run -p 6379:6379 --name gdz_redis  redis redis-server --appendonly yes
* start rails app
    * bundle exec passenger start
    * to check the queues access to: http://127.0.0.1:3000/sidekiq/
* start rescue
    * bundle exec sidekiq -q mets,5 -q collection,2 -q biblfileset,2 -q pagefileset,2 -q metsfileset,2
* begin import via: ruby ingest.rb

### with docker ###
* create an environment variable 'FCREPO_STORAE' pointing to the storage path
    * export FCREPO_STORAGE=</path/to/storage>
    * default is '/mnt/storage/' (see start.sh)
* create an environment variable  'RAILS_ENV' which modifies the container names
    * e.g.: export RAILS_ENV=development
    * if not set, '' will be used
* run the startscript: start.sh
* to add more worker run the following cli command
    * docker-compose scale worker=5             # to start 4 additional worker instances (if required)
* check: docker ps

* http://127.0.0.1                          # Blacklight
* http://127.0.0.1/sidekiq                  # sidekiq joblist

* http://127.0.0.1:8080                     # Fedora

* http://127.0.0.1:8983                     # solr
* http://127.0.0.1:3030                     # fuseki triplestore

