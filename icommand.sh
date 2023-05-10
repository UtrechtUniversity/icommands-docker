#!/bin/bash

COMMAND=$1
DATA_ROOT_HOST=$2
DATA_ROOT_CONTAINER=$3

USER_IRODS_FOLDER="~/.irods/"
CONTAINER_TAG="ghcr.io/utrechtuniversity/docker_icommands:0.1"

if [[ -z "$DATA_ROOT_HOST" ]]; then
    DATA_ROOT_HOST=/data/
fi

if [[ -z "$DATA_ROOT_CONTAINER" ]]; then
    DATA_ROOT_CONTAINER=/data/
fi

if [[ -z "$COMMAND" ]]; then
    COMMAND="ihelp"
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
