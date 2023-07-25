from ubuntu:22.04

ENV GITHUB_PAT ""
ENV RUNNER_LABELS ""
ENV GROUP_NAME ""
ENV RUNNER_VERSION "2.307.0"
ENV TERRAFORM_VERSION "1.5.2"

WORKDIR /opt

RUN apt-get update \
        && apt-get install -y jq curl git sudo vim unzip docker.io \
        && apt-get clean \
        && echo "sre ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ADD runapp.sh /opt/runapp.sh
ADD runsvc.sh /opt/runsvc.sh

# Create sre
RUN adduser --disabled-password --gecos "" sre \
	&& usermod -aG docker sre

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

# Change owner to SRE
RUN chown -R sre.sre /opt/* \
        && sudo chmod u+x /opt/runapp.sh /opt/runsvc.sh

VOLUME /var/lib/docker

# Default user
USER sre

ENTRYPOINT ["/opt/runapp.sh"]
