#!/usr/bin/env bash

ORG_NAME=$ORGANIZATION_NAME
TOKEN=$ACCESS_TOKEN

REGISTRATION_TOKEN=$(curl -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer ${TOKEN}" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/orgs/${ORG_NAME}/actions/runners/registration-token | jq .token --raw-output)
./config.sh --unattended --url https://github.com/${ORG_NAME} --token ${REGISTRATION_TOKEN} --labels docker-runner

cleanup() {
    echo "Removing runner from organization ${ORG_NAME}..."
    REMOVE_TOKEN=$(curl -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer ${TOKEN}" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/orgs/${ORG_NAME}/actions/runners/remove-token | jq .token --raw-output)
    ./config.sh remove --token ${REMOVE_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
