rm -rf "fcrepo4-data/"
curl "http://localhost:8983/solr/hydra-development/update" --data-binary "<delete><query>*:*</query></delete>" -H 'Content-type:text/xml; charset=utf-8'
curl "http://localhost:8983/solr/hydra-development/update"  --data-binary "<commit/>" -H 'Content-type:text/xml; charset=utf-8'
fcrepo_wrapper -p 8984


