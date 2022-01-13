#!/usr/bin/env bash

source $( which docker_chown_function )

docker_chown $( id -u "${NC_USER}" ) "${NC_BASE_PATH}"   $( id -g "${NC_USER}" )
