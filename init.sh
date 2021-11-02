#!/bin/bash

chown -R root:root /home/root/.ssh
/usr/sbin/sshd -D
