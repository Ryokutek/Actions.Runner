#!/usr/bin/env bash

if [[ ! -S /var/run/docker.sock ]]; then
    echo "Docker socket is missing"
	exit 1
fi

if [[ ! -r /var/run/docker.sock || ! -w /var/run/docker.sock ]]; then
    echo "Docker socket is missing read/write permission"
	exit 1
fi

GROUP_ID=$(stat -c '%g' '/var/run/docker.sock')

if ! getent group "$GROUP_ID" > /dev/null; then
	addgroup --gid "$GROUP_ID" docker
fi

GROUP_NAME=$(getent group "$GROUP_ID" | cut -d: -f1)

if ! groups runner-user | grep --quiet "\b${GROUP_NAME}\b"; then
	usermod --append --groups "$GROUP_ID" runner-user
fi

WORKING_DIRECTORY="running"
mkdir -p ${WORKING_DIRECTORY} && chown -R runner-user ${WORKING_DIRECTORY}

if [ "$RUNNER_TYPE" == "organization" ]; then
    ENTITY_URL="https://github.com/${ORGANIZATION_NAME}"
    REGISTRATION_URL="https://api.github.com/orgs/${ORGANIZATION_NAME}/actions/runners/registration-token"
    REMOVE_URL="https://api.github.com/orgs/${ORGANIZATION_NAME}/actions/runners/remove-token"
elif [ "$RUNNER_TYPE" == "repository" ]; then
    ENTITY_URL="https://github.com/${OWNER}/${REPOSITORY}"
    REGISTRATION_URL="https://api.github.com/repos/${OWNER}/${REPOSITORY}/actions/runners/registration-token"
    REMOVE_URL="https://api.github.com/repos/${OWNER}/${REPOSITORY}/actions/runners/remove-token"
else
    echo "Invalid RUNNER_TYPE environment variable value. Please set RUNNER_TYPE to 'organization' or 'repository'."
    exit 1
fi

ACCEPT_HEADER="Accept: application/vnd.github+json"
AUTHORIZATION_HEADER="Authorization: Bearer ${ACCESS_TOKEN}"
API_VERSION_HEADER="X-GitHub-Api-Version: ${API_VERSION}"

REGISTRATION_TOKEN=$(curl -L -X POST -H "${ACCEPT_HEADER}" -H "${AUTHORIZATION_HEADER}" -H "${API_VERSION_HEADER}" ${REGISTRATION_URL} | jq .token --raw-output)
sudo -u runner-user ./config.sh --unattended --url ${ENTITY_URL} --token ${REGISTRATION_TOKEN} --work ${WORKING_DIRECTORY} --labels docker-runner

cleanup() {
    echo "Started removing runner from ${ENTITY_URL}."

    REMOVE_TOKEN=$(curl -L -X POST -H "${ACCEPT_HEADER}" -H "${AUTHORIZATION_HEADER}" -H "${API_VERSION_HEADER}" ${REMOVE_URL} | jq .token --raw-output)
    sudo -u runner-user ./config.sh remove --token ${REMOVE_TOKEN}

    echo "Successfully finished removing runner from ${ENTITY_URL}."
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

sudo -u runner-user ./run.sh & wait $!
