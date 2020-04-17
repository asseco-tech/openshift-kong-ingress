#!/bin/bash

# Reading configuration
. ../../configure.env
. ../../deploy.env

# Validating tools
type oc > /dev/null 2>&1 || { echo >&2 "ERROR: oc program doesn't exist" && return 1; }
oc whoami > /dev/null 2>&1 || { echo >&2 "ERROR: You must login to OpenShift" && return 1; }

# active project variables
project_name="${run_project_name}${environment}"

# delete external services for kong routes
oc delete -n ${project_name}  $(oc get svc -l 'kong-route' -o name -n ${project_name})

# delete kong routes resources
oc delete -n ${project_name}  $(oc get ing,ki,kp,KongCredential,KongConsumer -o name -n ${project_name})
