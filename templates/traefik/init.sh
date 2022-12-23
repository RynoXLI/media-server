#!/bin/bash

# change directory to this file directory
cd "$(dirname "$0")"

# set environment variables
export $(grep -v '^#' .env | xargs -d '\n')
export $(grep -v '^#' ../../.env | xargs -d '\n')

# create config directory on your machine
mkdir -p ${DATA_LOCATION}/${SERVICE}/config

# copy over custom files
cp -r ./config/custom ${DATA_LOCATION}/${SERVICE}/custom

# create amce file
touch ${DATA_LOCATION}/${SERVICE}/config/acme.json
chmod 600 ${DATA_LOCATION}/${SERVICE}/config/acme.json

# create files
# https://stackoverflow.com/questions/14155596/how-to-substitute-shell-variables-in-complex-text-files
envsubst < config/config.sample.yml > ${DATA_LOCATION}/${SERVICE}/config/config.yml
envsubst < config/traefik.sample.yml > ${DATA_LOCATION}/${SERVICE}/config/traefik.yml

# setup password 
export USERPASS=$(echo $(htpasswd -nb admin $PASSWORD_TRAEFIK) | sed -e s/\\$/\\$\\$/g)
echo $USERPASS

# compile container
docker compose config > deploy.yml

# spin up container
docker compose -f deploy.yml up -d