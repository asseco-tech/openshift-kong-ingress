#!/bin/bash

# Reading configuration
. ../configure.env

# active project variable
project_name="${run_project_name}${environment}"
project_display="$(echo "${run_project_name} ${environment:1}" | tr a-z A-Z )"

# Validating tools
type oc > /dev/null 2>&1 || { echo >&2 "ERROR: oc program doesn't exist" && return 1; }
oc whoami > /dev/null 2>&1 || { echo >&2 "ERROR: You must login to OpenShift" && return 1; }

echo "+ Installing OpenShift' project ${project_name}"
oc process -f templates/kong-project-template.yaml \
  -p NAMESPACE="${project_name}" \
  -p NAMESPACE_DISPLAY="${project_display}" \
  -p NAMESPACE_DESC="${run_project_desc}" \
  -o yaml \
  > yaml.tmp && \
cat yaml.tmp | oc create -f -;

echo "+ Setting active project $project_name ..."
oc project ${project_name}
if [ $? -ne 0 ]; then return 1; fi

echo "+ Installing Account Resources"
oc process -f templates/kong-account-template.yaml \
  -p NAMESPACE="${project_name}" \
  -o yaml \
  > yaml.tmp && \
cat yaml.tmp | oc apply -f -;
if [ $? -ne 0 ]; then return 1; fi

rm -f *.tmp;

echo "+++ Adding system:image-puller role"
oc adm policy add-role-to-group system:image-puller system:serviceaccounts:${project_name} \
            --namespace=${project_build} \
            --rolebinding-name=${project_name}:image-puller;

echo "+ Installing ServiceAccount Policy"
oc adm policy add-scc-to-user anyuid -z kong-serviceaccount -n ${project_name}
oc adm policy add-scc-to-user anyuid -z default -n ${project_name}
