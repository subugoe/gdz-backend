#!/bin/sh


# --- storage

if [ -z ${FCREPO_STORAGE} ]; then export FCREPO_STORAGE=./data; fi

mkdir -p $FCREPO_STORAGE/fcrepo
mkdir -p $FCREPO_STORAGE/solr
mkdir -p $FCREPO_STORAGE/redis
mkdir -p $FCREPO_STORAGE/fuseki
chmod -R 744 $FCREPO_STORAGE


# --- modify compose file, depending on the plattform

unamestr=`uname`
if [[ "$unamestr" == "Darwin"* ]]; then
        sed -i.bak "s|    user: |    #user: |" docker-compose.yml
else
        sed -i "s|    user: |    #user: |" docker-compose.yml
fi


docker-compose build
docker-compose up -d