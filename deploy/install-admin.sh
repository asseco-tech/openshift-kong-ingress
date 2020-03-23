#!/bin/bash

# Reading configuration
. ../configure.env

# active project variable
project_name="${run_project_name}${environment}"

# Validating tools
type oc > /dev/null 2>&1 || { echo >&2 "ERROR: oc program doesn't exist" && return 1; }
oc whoami > /dev/null 2>&1 || { echo >&2 "ERROR: You must login to OpenShift" && return 1; }

echo "+ Installing Cluster Level Resources"
oc process -f kong-cluster-template.yaml \
  -o yaml \
  > yaml.tmp && \
cat yaml.tmp | oc apply -f -;
if [ $? -ne 0 ]; then return 1; fi

echo "+ Installing OpenShift' project ${project_name}"
oc process -f kong-project-template.yaml \
  -p NAMESPACE="${project_name}" \
  -p NAMESPACE_DESC="${run_project_desc}" \
  -o yaml \
  > yaml.tmp && \
# oddzielny projekt nie jest zakladany
cat yaml.tmp | oc apply -f -;
# TODO: -p NAMESPACE_DISPLAY="$( echo "${run_project_name} ${environment:1}" | tr a-z A-Z )" \
if [ $? -ne 0 ]; then return 1; fi

echo "+ Setting active project $project_name ..."
oc project ${project_name}
if [ $? -ne 0 ]; then return 1; fi

echo "+ Installing Project Level Resources"
oc process -f kong-account-template.yaml \
  -p NAMESPACE="${project_name}" \
  -o yaml \
  > yaml.tmp && \
cat yaml.tmp | oc apply -f -;
if [ $? -ne 0 ]; then return 1; fi

rm -f *.tmp;

echo "+ Installing ServiceAccount Policy"
oc adm policy add-scc-to-user anyuid -z kong-serviceaccount -n ${project_name}
oc adm policy add-scc-to-user anyuid -z default -n ${project_name}
