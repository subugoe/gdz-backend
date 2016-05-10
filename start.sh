#!/bin/sh

if [ -z ${FCREPO_STORAGE} ]; then export FCREPO_STORAGE=/mnt/storage; fi

mkdir -p $FCREPO_STORAGE/fcrepo
mkdir -p $FCREPO_STORAGE/solr
mkdir -p $FCREPO_STORAGE/redis
mkdir -p $FCREPO_STORAGE/fuseki


sed -i "s|    user: |    #user: |" docker-compose.yml

docker-compose build
docker-compose up -d