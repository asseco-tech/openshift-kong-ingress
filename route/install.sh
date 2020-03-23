#!/bin/bash

# Configure
cd "$(dirname "${BASH_SOURCE[0]}")"
source yaml.sh
. ../configure.env

# cli param
param_mode=${1:-apply}
if [[ ! "${param_mode}" =~ ^(apply|create|delete)$ ]]; then
    echo "Usage: ./install.sh [apply|create|delete]"
    exit 1
fi


# Validating tools
type oc > /dev/null 2>&1 || { echo >&2 "ERROR: oc program doesn't exist" && exit 1; }
oc whoami > /dev/null 2>&1 || { echo >&2 "ERROR: You must login to OpenShift" && exit 1; }

# Execute parsing yaml
create_variables ./kong-routes.yaml

# openshift project
echo "+ Setting active project $route_project_name ..."
oc project ${route_project_name}
if [ $? -ne 0 ]; then exit 1; fi


# Apply plugin template
if [ -f kong-plugins-template.yaml ]; then
    echo "++ Applying Global Plugin Template ..."
    oc process -f kong-plugins-template.yaml \
      -p ingress_class="${kong_ingress_class}" \
      -p key_claim_name="${kong_jwt_provider_key_claim_name}" \
      -p key_claim_value="${kong_jwt_provider_key_claim_value}" \
      -p rsa_public_key="${kong_jwt_provider_rsa_public_key}" \
      -o yaml \
      > yaml.tmp && \
    cat yaml.tmp | oc $param_mode -f -
    [ $? -ne 0 ] && [ "$param_mode" != "delete" ] && exit 1
    rm -f *.tmp
fi

# Apply route template loop
let i=0
while [ "${kong_routes__name[i]}" != "" ]
do
    echo "++ Route: ${kong_routes__name[i]}"

    if [ "${kong_routes__external_service_name[i]}" != "null" ] && [ "${kong_routes__external_service_name[i]}" != "" ]; then
        echo "+ Applying External Service: ${kong_routes__external_service_name[i]}"
        oc process -f kong-service-template.yaml \
          -p route_name="${kong_routes__name[i]}" \
          -p service_name="${kong_routes__service_name[i]}" \
          -p service_port=${kong_routes__service_port[i]} \
          -p external_service_name="${kong_routes__external_service_name[i]}" \
          -o yaml \
          > yaml.tmp && \
        cat yaml.tmp | oc $param_mode -f -
        [ $? -ne 0 ] && [ "$param_mode" != "delete" ] && (rm -f *.tmp; exit 1;)
        rm -f *.tmp
    fi

    route_plugins=""
    if [ "${kong_routes__route_plugins[i]}" != "null" ] && [ "${kong_routes__route_plugins[i]}" != "" ]; then
        route_plugins=", ${kong_routes__route_plugins[i]}"
    fi

    echo "+ Applying Route Template ..."
    oc process -f kong-route-template.yaml \
      -p ingress_class="${kong_ingress_class}" \
      -p route_name="${kong_routes__name[i]}" \
      -p route_path="${kong_routes__route_path[i]}" \
      -p route_plugins="${route_plugins}" \
      -p service_name="${kong_routes__service_name[i]}" \
      -p service_port=${kong_routes__service_port[i]} \
      -p rewrite_path="${kong_routes__rewrite_path[i]}" \
      -o yaml \
      > yaml.tmp && \
    cat yaml.tmp | oc $param_mode -f -
    [ $? -ne 0 ] && [ "$param_mode" != "delete" ] && (rm -f *.tmp; exit 1;)
    rm -f *.tmp

    let i++
done

#echo
#set | grep kong_

cd -
