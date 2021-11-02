#!/bin/bash

chown -R root:root /root/.ssh
/usr/sbin/sshd -D
