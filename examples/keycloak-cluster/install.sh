#!/bin/bash

# Configure
cd "$(dirname "${BASH_SOURCE[0]}")"
. ../../configure.env
. ../../deploy.env
. ./deploy.env

# cli param
param_mode=${1:-apply}
if [[ ! "${param_mode}" =~ ^(apply|create|delete)$ ]]; then
    echo "Usage: ./install.sh [apply|create|delete]"
    exit 1
fi

# Validating tools
type oc > /dev/null 2>&1 || { echo >&2 "ERROR: oc program doesn't exist" && exit 1; }
oc whoami > /dev/null 2>&1 || { echo >&2 "ERROR: You must login to OpenShift" && exit 1; }

# openshift project
echo "+ Setting active project $route_project_name ..."
oc project ${route_project_name}
if [ $? -ne 0 ]; then exit 1; fi

# Delete standard route template
echo "+ Deleting Keycloak Route ..."
oc delete ki upstream-service-${keycloak_service_name}
oc delete svc ${keycloak_service_name}

# Apply route template
echo "+ Applying Keycloak Cluster Template ..."
oc process -f kong-keycloak-cluster.yaml \
  -p route_name="${keycloak_route_name}" \
  -p ingress_class="${kong_ingress_class}" \
  -p service_name="${keycloak_service_name}" \
  -p service_port=${keycloak_port} \
  -p service_protocol=${keycloak_protocol} \
  -p keycloak_realm=${keycloak_realm} \
  -p keycloak_host1=${keycloak_host} \
  -p keycloak_host2=${keycloak_host2} \
  -p keycloak_host3=${keycloak_host3} \
  -o yaml \
  > yaml.tmp && \
cat yaml.tmp | oc $param_mode -f -
[ $? -ne 0 ] && [ "$param_mode" != "delete" ] && (rm -f *.tmp; exit 1;)
rm -f *.tmp

cd -
