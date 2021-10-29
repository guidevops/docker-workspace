FROM ubuntu:focal AS base

ENV DEBIAN_FRONTEND noninteractive

# Setup Base Packages

RUN apt-get -qq update \
    && apt-get -qq --no-install-recommends install sudo=1.8.* \
    && apt-get -qq --no-install-recommends install openssh-server=1:8.* \
    && apt-get -qq --no-install-recommends install git \
    && apt-get -qq --no-install-recommends install ca-certificates \
    && apt-get -qq --no-install-recommends install curl \
    && apt-get -qq --no-install-recommends install vim-tiny=2:8.1.* \
    && apt-get -qq --no-install-recommends install nano \
    && apt-get -qq clean    \
    && rm -rf /var/lib/apt/lists/* 


# Configure SSH
RUN mkdir /var/run/sshd
RUN ex +"%s/^%sudo.*$/%sudo ALL=(ALL:ALL) NOPASSWD:ALL/g" -scwq! /etc/sudoers
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Setup the default user.
RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo ubuntu
RUN addgroup ubuntu
RUN adduser ubuntu ubuntu
RUN echo 'ubuntu:ubuntu' | chpasswd
USER ubuntu
WORKDIR /home/ubuntu

#Setup VS Code Server

ARG commit_id=c13f1abb110fc756f9b3a6f16670df9cd9d4cf63
RUN curl -sSL "https://update.code.visualstudio.com/commit:${commit_id}/server-linux-x64/stable" -o /tmp/vscode-server-linux-x64.tar.gz \
    && mkdir -p ~/.vscode-server/bin/${commit_id} \
    && tar zxvf /tmp/vscode-server-linux-x64.tar.gz -C ~/.vscode-server/bin/${commit_id} --strip 1 

FROM base AS node
#Setup Node Packages
USER root
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install nodejs -y\
    && npm install -g yarn@latest \
    && npm install -g npm@latest \
    && apt-get -qq clean    \
    && rm -rf /var/lib/apt/lists/* 

ADD init.sh /init.sh
RUN chmod +x /init.sh
# Setup User Ubuntu.
#USER ubuntu

EXPOSE 22
EXPOSE 8080
#CMD ["/usr/bin/sudo", "/usr/sbin/sshd", "-D", "-o", "ListenAddress=0.0.0.0"]
CMD ["/init.sh"]


FROM base AS devops
#Setup DevOps Packages
USER root

##Install Ansible + Terraform
RUN apt-get -qq update \
    && apt-get -qq --no-install-recommends install software-properties-common gpg-agent \
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - \
    && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    && apt-get -qq clean    \
    && rm -rf /var/lib/apt/lists/* 


RUN apt-get -qq update \
    && apt-get -qq --no-install-recommends install terraform \
    && apt-get -qq --no-install-recommends install ansible \
    && apt-get -qq clean    \
    && rm -rf /var/lib/apt/lists/* 


# Setup default command and/or parameters.
EXPOSE 22
CMD ["/usr/bin/sudo", "/usr/sbin/sshd", "-D", "-o", "ListenAddress=0.0.0.0"]

