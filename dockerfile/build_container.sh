#!/bin/bash

CONTAINER_TAG=$1

if [[ -z "$CONTAINER_TAG" ]]; then
    CONTAINER_TAG="icommands:0.1"
fi

sudo docker build -t ${CONTAINER_TAG} .