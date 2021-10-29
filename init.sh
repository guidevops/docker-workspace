#!/bin/bash

sudo chown -R ubuntu:ubuntu /home/ubuntu/.ssh
sudo /usr/sbin/sshd -D
