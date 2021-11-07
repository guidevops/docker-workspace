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
    && apt-get -qq --no-install-recommends install  python-pkg-resources \
    && apt-get -qq clean    \
    && rm -rf /var/lib/apt/lists/* 

#Configure Docker-compose
RUN curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    && ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Configure SSH
RUN mkdir /var/run/sshd
RUN ex +"%s/^%sudo.*$/%sudo ALL=(ALL:ALL) NOPASSWD:ALL/g" -scwq! /etc/sudoers
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config



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


EXPOSE 22
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

ADD init.sh /init.sh
RUN chmod +x /init.sh

# Setup default command and/or parameters.
EXPOSE 22
CMD ["/init.sh"]

