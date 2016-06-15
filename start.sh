#!/bin/sh


# --- storage

if [ -z ${FCREPO_STORAGE} ]; then export FCREPO_STORAGE=/mnt/storage/gdz_be; fi
if [ -z ${RAILS_ENV} ]; then export RAILS_ENV=development; fi

mkdir -p $FCREPO_STORAGE/fcrepo
mkdir -p $FCREPO_STORAGE/solr
mkdir -p $FCREPO_STORAGE/redis
mkdir -p $FCREPO_STORAGE/fuseki



docker-compose build
docker-compose up -d
