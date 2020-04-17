#!/bin/bash

# Reading configuration
. ../configure.env
. ../deploy.env

# active project variable
project_name="${run_project_name}${environment}"

# Validating tools
type oc > /dev/null 2>&1 || { echo >&2 "ERROR: oc program doesn't exist" && return 1; }
oc whoami > /dev/null 2>&1 || { echo >&2 "ERROR: You must login to OpenShift" && return 1; }

# CHECK
oc get svc -l 'kong-route' -n ${project_name}
oc get ing,ki,kp,KongCredential,KongConsumer -n ${project_name}
