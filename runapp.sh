#!/bin/sh

# Generate Runner token
export RUNNER_TOKEN=$(curl -s -X POST https://api.github.com/orgs/${ORGANIZATION_NAME}/actions/runners/registration-token -H "accept: application/vnd.github.everest-preview+json" -H "authorization: token ${GITHUB_PAT}" | jq -r '.token')

cd /opt
sudo chown -R sre.sre /opt/

echo "Configuring runner."
./config.sh --unattended --no-default-labels --labels self-hosted-${GROUP_NAME} --runnergroup ${GROUP_NAME} --url https://github.com/${ORGANIZATION_NAME} --token ${RUNNER_TOKEN}
sudo chmod u+x /opt/runsvc.sh /opt/runapp.sh

echo "Running runner."
/opt/runsvc.sh "$*" &

wait $!
