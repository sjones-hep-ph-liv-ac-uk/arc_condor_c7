#!/bin/bash

condor_status  | grep slot1@ | sed -e "s/slot1.//" -e "s/\..*//" | sort

