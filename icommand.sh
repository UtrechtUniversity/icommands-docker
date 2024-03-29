#!/bin/bash

COMMAND=$1
DATA_ROOT_HOST=$2
DATA_ROOT_CONTAINER=$3

USER_IRODS_FOLDER="/data/yoda/irods/"
CONTAINER_TAG="ghcr.io/utrechtuniversity/docker_icommands:0.2"

if [[ -z "$DATA_ROOT_HOST" ]]; then
    DATA_ROOT_HOST=/data/yoda/upload/
fi

if [[ -z "$DATA_ROOT_CONTAINER" ]]; then
    DATA_ROOT_CONTAINER=${DATA_ROOT_HOST}
fi

if [[ -z "$COMMAND" ]]; then
    COMMAND="ihelp"
fi

echo "Data root mapping: ${DATA_ROOT_HOST}:${DATA_ROOT_CONTAINER}"

docker run -it --rm \
    -v ${USER_IRODS_FOLDER}:/root/.irods/ \
    -v ${DATA_ROOT_HOST}:${DATA_ROOT_CONTAINER} \
    ${CONTAINER_TAG} \
    $COMMAND
