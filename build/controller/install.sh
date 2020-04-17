#!/bin/bash

# Reading configuration
. ../../configure.env
. ../../deploy.env

# active project variable
project_build=$(echo "${build_project_name}${environment}")

# image configuration
image_name="${controller_image_name}"
image_tag="${controller_image_tag}"
custom_image_name="${custom_controller_image_name}"
image_baseurl="${controller_image_baseurl}"
build_name="${custom_image_name}-${image_tag//./-}"

# Validating tools
type oc > /dev/null 2>&1 || { echo >&2 "ERROR: oc program doesn't exist" && return 1; }
oc whoami > /dev/null 2>&1 || { echo >&2 "ERROR: You must login to OpenShift" && return 1; }

echo "+ Setting active project $project_build ..."
oc project ${project_build}
if [ $? -ne 0 ]; then return 1; fi

# import base image from docker.io
oc import-image ${image_baseurl}/${image_name}:${image_tag} 2>&1 | \
  grep -iE 'Error|NotFound' | while read line;do \
    echo "Import image ${image_baseurl}/${image_name}:${image_tag} ..."; \
    oc import-image ${image_name}:${image_tag} --from="${image_baseurl}/${image_name}:${image_tag}" --confirm; \
  done;

# creating Dockerfile
tmp_folder="temp-build"
echo "+ Processing Dockerfile into: ${tmp_folder}"
[ -d "${tmp_folder}" ] \
    &&  rm -rf ${tmp_folder}
mkdir ${tmp_folder}

local_plugins=""
[ -n "$kong_plugins" ] \
    && local_plugins=",${kong_plugins}"

cat Dockerfile \
   | sed -e "s/\${IMAGE_NAME}/${image_name}/g"   \
         -e "s/\${IMAGE_TAG}/${image_tag}/g"     \
         -e "s/\${KONG_PLUGINS}/${local_plugins}/g"     \
   > ${tmp_folder}/Dockerfile

[ -d plugins ] && cp -pr plugins ${tmp_folder}/
cp -pr ../*probe*.sh ${tmp_folder}/

# creating image build
echo "+ Image Build: ${build_name}"
oc get bc ${build_name} 2>&1 | grep -iE 'Error|NotFound' | while read line;do \
   echo "BuildConfig ${build_name}"; \
   oc new-build --strategy docker --binary \
                --name ${build_name} \
                --to="${custom_image_name}:${image_tag}" ;\
   if [ $? -ne 0 ]; then return 1; fi; \
done;

oc start-build ${build_name} --from-dir=${tmp_folder} --follow
