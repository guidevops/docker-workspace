#!/bin/bash

/usr/sbin/sshd -D &
code-server --auth none --bind-addr 0.0.0.0:8384