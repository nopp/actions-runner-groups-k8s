#!/bin/sh

# Generate Runner token
export RUNNER_TOKEN=$(curl -s -X POST https://api.github.com/orgs/${ORGANIZATION_NAME}/actions/runners/registration-token -H "accept: application/vnd.github.everest-preview+json" -H "authorization: token ${GITHUB_PAT}" | jq -r '.token')

# Remove the runner
cd /opt
sudo -E -u sre ./config.sh remove --token ${RUNNER_TOKEN}
