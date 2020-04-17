#!/bin/bash

# Reading configuration
. ../configure.env
. ../deploy.env

# Validating tools
type oc > /dev/null 2>&1 || { echo >&2 "ERROR: oc program doesn't exist" && return 1; }
oc whoami > /dev/null 2>&1 || { echo >&2 "ERROR: You must login to OpenShift" && return 1; }

echo "+ Installing Cluster Level Resources"
oc process -f templates/kong-cluster-template.yaml \
  -o yaml \
  > yaml.tmp && \
cat yaml.tmp | oc apply -f -;
if [ $? -ne 0 ]; then return 1; fi

rm -f *.tmp;
