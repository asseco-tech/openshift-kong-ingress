#!/bin/bash

#Odczytanie konfiguracji
. ../configure.env

project_build=`echo "${build_project_name}${environment}"`
echo "Aktualny projekt: $project_build"

oc project $project_build
if [ $? -ne 0 ]; then return 1; fi

oc logs bc/${build_name} -f
