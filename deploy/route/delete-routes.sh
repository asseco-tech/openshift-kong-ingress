#!/bin/bash

# Reading configuration
. ../../configure.env
. ../../deploy.env

# active project variables
project_name="${run_project_name}${environment}"

# delete external services for kong routes
oc delete -n ${project_name}  $(oc get svc -l 'kong-route' -o name -n ${project_name})

# delete kong routes resources
oc delete -n ${project_name}  $(oc get ing,ki,kp,KongCredential,KongConsumer -o name -n ${project_name})
