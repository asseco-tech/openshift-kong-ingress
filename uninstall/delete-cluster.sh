#!/bin/bash

# Reading configuration
. ../configure.env

oc delete -f kong-cluster-deletes.yaml
