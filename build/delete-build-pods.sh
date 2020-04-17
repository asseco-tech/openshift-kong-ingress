#!/bin/bash

# Reading configuration
. ../configure.env
. ../deploy.env

# Validating tools
type oc > /dev/null 2>&1 || { echo >&2 "ERROR: oc program doesn't exist" && return 1; }
oc whoami > /dev/null 2>&1 || { echo >&2 "ERROR: You must login to OpenShift" && return 1; }

# active project variable
project_build=$(echo "${build_project_name}${environment}")

echo "+ Setting active project $project_build ..."
oc project ${project_build}
if [ $? -ne 0 ]; then return 1; fi

# check pods
oc get pod -l 'openshift.io/build.name' -o name | grep kong > /dev/null
if [ $? -ne 0 ]; then return 1; fi

# delete build pods
oc delete $(oc get pod -l 'openshift.io/build.name' -o name)
