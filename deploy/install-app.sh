#!/bin/bash

# Reading configuration
. ../configure.env

# function: create_configmap
function create_configmap()
{
  local cf_name=$1
  local cf_path=$2
  local from_file=""

  for file in `ls ${cf_path} 2> /dev/null`; do
    from_file="${from_file} --from-file=$file";
  done;

  oc create configmap ${cf_name} ${from_file}
}

# active project variable
project_name="${run_project_name}${environment}"
project_build=`echo "${build_project_name}${environment}"`


# Validating tools
type oc > /dev/null 2>&1 || { echo >&2 "ERROR: oc program doesn't exist" && return 1; }
oc whoami > /dev/null 2>&1 || { echo >&2 "ERROR: You must login to OpenShift" && return 1; }

echo "+ Setting active project $project_name ..."
oc project ${project_name}
if [ $? -ne 0 ]; then return 1; fi


# Installing Plugin Configmaps
if [ -d "./plugins" ]; then
    echo "+ Installing Plugin Configmaps"
    for folder in $(ls ./plugins 2> /dev/null); do
        plugin_name=$(basename $folder)
        if [ -d "./plugins/${plugin_name}/plugin" ]; then
            create_configmap "${plugin_name}" "./plugins/${plugin_name}/plugin/*.lua"
        else
            create_configmap "${plugin_name}" "./plugins/${plugin_name}/*.lua"
        fi
    done;
fi

echo "+ Installing INGRESS-KONG application"
oc process -f templates/kong-controller-template.yaml \
  -p NAMESPACE=${project_name} \
  -p INGRESS_CLASS_ID=${kong_ingress_class} \
  -p KONG_PROXY_HTTP_HOST=${kong_proxy_host} \
  -p KONG_PROXY_INSECURE_EDGE=$( ${kong_proxy_http_allow} && echo 'Allow' || echo 'None' ) \
  -p KONG_PROXY_WILDCARD_POLICY=$( ${kong_proxy_subdomain_allow} && echo 'Subdomain' || echo 'None' ) \
  -p KONG_IMAGE_NAME=${kong_image_path} \
  -p KONG_IMAGE_TAG=${kong_image_tag} \
  -p KONG_CONTROLLER_IMAGE_NAME=${kong_controller_image_name} \
  -p KONG_CONTROLLER_IMAGE_TAG=${kong_controller_image_tag} \
  -p KONG_PROXY_MEMORY_LIMIT=${kong_proxy_memory_limit} \
  -o yaml \
  > yaml.tmp && \
cat yaml.tmp | oc apply -f -
if [ $? -ne 0 ]; then return 1; fi

echo "+ Installing KONGA-UI application"
oc process -f templates/konga-ui-template.yaml \
  -p KONGA_IMAGE_NAME=${konga_image_name} \
  -p KONGA_IMAGE_TAG=${konga_image_tag} \
  -p ADMIN_USER_PASS=${konga_admin_user_pass} \
  -p KONGA_INSECURE_EDGE=$( ${konga_http_allow} && echo 'Allow' || echo 'None' ) \
  -o yaml \
  > yaml.tmp && \
cat yaml.tmp | oc apply -f -

rm -f *.tmp
