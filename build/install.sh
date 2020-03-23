#!/bin/bash

# Reading configuration
. ../configure.env

# active project variable
project_build=`echo "${build_project_name}${environment}"`

# Validating tools
type oc > /dev/null 2>&1 || { echo >&2 "ERROR: oc program doesn't exist" && return 1; }
oc whoami > /dev/null 2>&1 || { echo >&2 "ERROR: You must login to OpenShift" && return 1; }

echo "+ Setting active project $project_build ..."
oc project ${project_build}
if [ $? -ne 0 ]; then return 1; fi

# creating Dockerfile
tmp_folder="temp-app"
echo "+ Processing Dockerfile into: ${tmp_folder}"
[ -d "${tmp_folder}" ]  &&  rm -rf ${tmp_folder}
mkdir ${tmp_folder}
cat Dockerfile \
   | sed -e "s/\${IMAGE_NAME}/${kong_image_name}/g"   \
         -e "s/\${IMAGE_TAG}/${kong_image_tag}/g"     \
   > ${tmp_folder}/Dockerfile

# creating image build
echo "+ Image Build: ${build_name}"
oc get bc ${build_name} 2>&1 | grep -iE 'Error|NotFound' | while read line;do \
   echo "BuildConfig ${build_name}"; \
   oc new-build --strategy docker --binary --name ${build_name} --to="${custom_kong_image_name}:${kong_image_tag}" ;\
  done;
if [ $? -ne 0 ]; then return 1; fi
oc start-build ${build_name} --from-file=${tmp_folder}/Dockerfile
