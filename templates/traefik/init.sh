#!/bin/bash

# change directory to this file directory
cd "$(dirname "$0")"

# set environment variables
export $(grep -v '^#' .env | xargs -d '\n')
export $(grep -v '^#' ../../.env | xargs -d '\n')

# create files
# https://stackoverflow.com/questions/14155596/how-to-substitute-shell-variables-in-complex-text-files
envsubst < config/config.sample.yml > config/config.yml
envsubst < config/traefik.sample.yml > config/traefik.yml

# setup password 
export USERPASS=$(echo $(htpasswd -nb admin $PASSWORD_TRAEFIK) | sed -e s/\\$/\\$\\$/g)
echo $USERPASS

# compile container
docker compose config > deploy.yml

# spin up container
docker compose -f deploy.yml up -d