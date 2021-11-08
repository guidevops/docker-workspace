#!/bin/bash

DOCKER_BUILDKIT=1 docker build . \
                                --target devops \
                                -t workspace-devops

DOCKER_BUILDKIT=1 docker build . \
                                --target node \
                                -t workspace-node

DOCKER_BUILDKIT=1 docker build . \
                                --build-arg STAGE_VERSION=code \
                                --build-arg INIT=init_code  \
                                --target devops \
                                -t workspace-devops-code
DOCKER_BUILDKIT=1 docker build . \
                                --build-arg STAGE_VERSION=code \
                                --build-arg INIT=init_code  \
                                --target node   \
                                -t workspace-node-code
