#!/bin/bash

# Configure
cd "$(dirname "${BASH_SOURCE[0]}")"
source scripts/yaml.sh
. ../../configure.env
. ../../deploy.env

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


# Apply common plugins template
if [ -f templates/kong-plugins-template.yaml ]; then
    echo "++ Applying Global Plugin Template ..."
    oc process -f templates/kong-plugins-template.yaml \
      -p ingress_class="${kong_ingress_class}" \
      -p request_per_second=${kong_throttling_request_per_second:-100} \
      -p request_per_minute=${kong_throttling_request_per_minute:-2000} \
      -p rate_limit_by="${kong_throttling_limit_by:-ip}" \
      -o yaml \
      > yaml.tmp && \
    cat yaml.tmp | oc $param_mode -f -
    [ $? -ne 0 ] && [ "$param_mode" != "delete" ] && exit 1
    rm -f *.tmp
fi


# Apply JWT plugin template
if [ -f templates/kong-plugin-jwt-template.yaml ] && [ "${jwt_key_claim_name}" != "null" ] && [ "${jwt_key_claim_value}" != "" ]; then
    echo "++ Applying JWT Plugin Template ..."
    oc process -f templates/kong-plugin-jwt-template.yaml \
      -p ingress_class="${kong_ingress_class}" \
      -p key_claim_name="${jwt_key_claim_name}" \
      -p key_claim_value="${jwt_key_claim_value}" \
      -p rsa_public_key="${jwt_rsa_public_key}" \
      -o yaml \
      > yaml.tmp && \
    cat yaml.tmp | oc $param_mode -f -
    [ $? -ne 0 ] && [ "$param_mode" != "delete" ] && exit 1
    rm -f *.tmp
fi


# Apply Basic-Auth plugin template
if [ -f templates/kong-plugin-basicauth-template.yaml ] && [ "${basic_username}" != "" ]; then
    echo "++ Applying Basic Auth Plugin Template ..."
    oc process -f templates/kong-plugin-basicauth-template.yaml \
      -p ingress_class="${kong_ingress_class}" \
      -p username="${basic_username}" \
      -p password="${basic_password}" \
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
        service_protocol="${kong_routes__service_protocol[i]:-http}"
        if [ "${service_protocol}" == "null" ]; then
            service_protocol="http"
        fi

        oc process -f templates/kong-service-template.yaml \
          -p route_name="${kong_routes__name[i]}" \
          -p service_name="${kong_routes__service_name[i]}" \
          -p service_port=${kong_routes__service_port[i]} \
          -p service_protocol="${service_protocol}" \
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

    if [ "${kong_routes__request_size_limit[i]}" != "null" ] && [ "${kong_routes__request_size_limit[i]}" != "" ]; then
        plugin_size="plugin-size-limit-${kong_routes__name[i]}"
        echo "+ Applying Size Limiting Plugin ..."
        oc process -f templates/kong-plugin-size-limit-template.yaml \
          -p ingress_class="${kong_ingress_class}" \
          -p route_name="${kong_routes__name[i]}" \
          -p request_size=${kong_routes__request_size_limit[i]} \
          -o yaml \
          > yaml.tmp && \
        cat yaml.tmp | oc $param_mode -f -
        [ $? -ne 0 ] && [ "$param_mode" != "delete" ] && (rm -f *.tmp; exit 1;)
        rm -f *.tmp

        route_plugins="${route_plugins}, ${plugin_size}"
    fi

    echo "+ Applying Route Template ..."
    oc process -f templates/kong-route-template.yaml \
      -p ingress_class="${kong_ingress_class}" \
      -p route_name="${kong_routes__name[i]}" \
      -p route_path="${kong_routes__route_path[i]}" \
      -p route_priority=${kong_routes__priority[i]} \
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

[ -f kong-external-services.yaml ] \
    && oc $param_mode -f kong-external-services.yaml

cd -
