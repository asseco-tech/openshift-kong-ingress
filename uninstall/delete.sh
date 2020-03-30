#!/bin/bash

# Reading configuration
. ../configure.env

# active project variable
project_name="${run_project_name}${environment}"
project_build=`echo "${build_project_name}${environment}"`

oc delete -f kong-account-deletes.yaml -n ${project_name}
oc delete project ${project_name}

oc delete bc ${build_name} -n ${project_build}
