#!/bin/bash

export _SYSTEMCTL_SKIP_REDIRECT=1

service nordugrid-arc-slapd start
service nordugrid-arc-bdii start
service nordugrid-arc-inforeg start


