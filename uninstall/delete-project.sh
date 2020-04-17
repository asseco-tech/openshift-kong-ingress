#!/bin/bash

# Reading configuration
. ../configure.env
. ../deploy.env

# Validating tools
type oc > /dev/null 2>&1 || { echo >&2 "ERROR: oc program doesn't exist" && return 1; }
oc whoami > /dev/null 2>&1 || { echo >&2 "ERROR: You must login to OpenShift" && return 1; }

# active project variables
project_name="${run_project_name}${environment}"
project_build=$(echo "${build_project_name}${environment}")

# delete project
oc delete -n ${project_name}  $(oc get dc,svc,route,cm -o name -n ${project_name})
oc delete project ${project_name}

# delete role binding
oc delete ClusterRoleBinding kong-ingress-clusterrole-binding-${project_name}

# delete build
oc delete bc ${build_name} -n ${project_build}
