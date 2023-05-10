#!/bin/bash

COMMAND=$1
DATA_ROOT_HOST=$2
DATA_ROOT_CONTAINER=$3

USER_IRODS_FOLDER="/data/hyde/irods/"
CONTAINER_TAG="icommands:0.1"

if [[ -z "$DATA_ROOT_HOST" ]]; then
    DATA_ROOT_HOST=/data/hyde/
fi

if [[ -z "$DATA_ROOT_CONTAINER" ]]; then
    DATA_ROOT_CONTAINER=/data/hyde/
fi

echo "Data root mapping: ${DATA_ROOT_HOST} --> ${DATA_ROOT_CONTAINER}"

docker run -i --rm \
    -v ${USER_IRODS_FOLDER}:/root/.irods/ \
    -v ${DATA_ROOT_HOST}:${DATA_ROOT_CONTAINER} \
    ${CONTAINER_TAG} \
    $COMMAND

echo docker run -i --rm \
    -v ${USER_IRODS_FOLDER}:/root/.irods/ \
    -v ${DATA_ROOT_HOST}:${DATA_ROOT_CONTAINER} \
    ${CONTAINER_TAG} \
    $COMMAND




# https://docs.irods.org/master/icommands/user/
# /nluu12p/home/research-test-christine/maarten/ -o upload -l /data/ibridges/upload/


#   need env file (mapped)
#   iinit --> enter password, creates .rodsA; do 'ipasswd' (of iinit) when password expires (explain where in Yoda to set/get)
#   ils, ilsresc (maar default)
#   irsync
#   Ctrl+C werkt niet: kill container (how?)
# ./icommand.sh "irsync -rv /data/integration_tests/ i:/nluu12p/home/research-test-christine/maarten/hyde/"

