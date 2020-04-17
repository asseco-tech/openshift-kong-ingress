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
oc get dc,pod,route,cm -n ${project_name}
oc get svc -l 'app' -n ${project_name}
