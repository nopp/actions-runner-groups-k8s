from ubuntu:22.04

ENV GITHUB_PAT ""
ENV RUNNER_LABELS ""
ENV GROUP_NAME ""
ENV RUNNER_VERSION "2.311.0"
ENV TERRAFORM_VERSION "1.5.2"
ENV DOCKER_CREDENTIAL_GCR "2.1.11"
ENV NEWRELIC_VERSION "0.76.3"

USER root

WORKDIR /opt

RUN apt-get update \
        && apt-get install -y jq curl git sudo vim unzip docker.io make \
        && apt-get clean \
        && echo "sre ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ADD runapp.sh /opt/runapp.sh
ADD runsvc.sh /opt/runsvc.sh
ADD removeRunner.sh /opt/removeRunner.sh

# Create sre
RUN adduser --disabled-password --gecos "" sre \
	&& usermod -aG docker sre

# Newrelic Cli
RUN curl -k -LO  https://github.com/newrelic/newrelic-cli/releases/download/v${NEWRELIC_VERSION}/newrelic-cli_${NEWRELIC_VERSION}_Linux_x86_64.tar.gz \
	&& tar xzf newrelic-cli_${NEWRELIC_VERSION}_Linux_x86_64.tar.gz \
 	&& install -o root -g root -m 0755 newrelic /usr/local/bin/newrelic \
  	&& rm -rf newrelic-cli_${NEWRELIC_VERSION}_Linux_x86_64.tar.gz

# Terraform
RUN  curl -k -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
        && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
        && install -o root -g root -m 0755 terraform /usr/local/bin/terraform \
	&& rm -rf terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Kubectl
RUN curl -k -LO "https://dl.k8s.io/release/$(curl -k -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
        && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
        && rm -rf kubectl

# Actions Runner
RUN curl -fkLO  https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
        && tar xzf actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
        && ./bin/installdependencies.sh \
        && rm -rf actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# docker-credential-gcloud
RUN  curl -k -LO https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v${DOCKER_CREDENTIAL_GCR}/docker-credential-gcr_linux_amd64-${DOCKER_CREDENTIAL_GCR}.tar.gz \
        && tar xzf docker-credential-gcr_linux_amd64-${DOCKER_CREDENTIAL_GCR}.tar.gz \
        && install -o root -g root -m 0755 docker-credential-gcr /usr/local/bin/docker-credential-gcr \
	&& install -o root -g root -m 0755 docker-credential-gcr /usr/local/bin/docker-credential-gcloud \
	&& rm -rf docker-credential-gcr_linux_amd64-${DOCKER_CREDENTIAL_GCR}.tar.gz

# Change owner to SRE
 RUN chown -R sre.sre /opt/* \
         && sudo chmod u+x /opt/runapp.sh /opt/runsvc.sh /opt/removeRunner.sh

VOLUME /var/lib/docker

ENTRYPOINT ["/opt/runapp.sh"]
