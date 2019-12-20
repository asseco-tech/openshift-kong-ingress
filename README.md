# openshift-kong-ingress
OpenShift Deployment for Kong API Gateway and Konga GUI.

Repository address: https://github.com/asseco-tech/openshift-kong-ingress/

## Content
It is OpenShift edition of [Kong for Kubernetes](https://github.com/Kong/kubernetes-ingress-controller) scripts and 
[Konga GUI Deployment](https://github.com/pantsel/konga).
Kong is deploying as Ingress Controller, so You can create routing by Ingress resource and by Custom Resource Definitions(CRDs).
Konga is nice GUI dashboard for Kong.
 
OpenShift edition has added some permission resources and converted to OpenShift specific resources.


## Compatiblity
**openshift-kong-ingress** has tested with:
 - OpenShift 3.11
 - Kong 1.4.0
 - Kong Controller 0.6.2
 - Konga 0.14.7

 
## Automated Installing
Configuration in:
```
configure.env
```
Running scripts:
```sh
cd deploy
    . install-admin.sh
    . install.sh
```  
Script `install-admin.sh` requires **cluster-admin** role.   
Script `install.sh` requires only local project **admin** role.

## Custom Installing
You can use `*.yaml` templates (look at [deploy](deploy) folder) to install them
by custom solution. You just have to keep order according to the table below:

| Order | Template or script           | Required Role | Scope   |
|-------|------------------------------|---------------|---------|
| 1     | kong-cluster-template.yaml   | cluster-admin | cluster |
| 2     | kong-project-template.yaml   | cluster-admin | cluster |
| 3     | kong-account-template.yaml   | cluster-admin | project |
| 4     | [scc-script](#scc-script)    | cluster-admin | project |
| 5     | kong-controller-template.yaml| local admin   | project |
| 6     | konga-ui-template.yaml       | local admin   | project |

Every template contains parameters with some documentation inside.

#### scc-script
```
project_name=<kong-project>
oc adm policy add-scc-to-user anyuid -z kong-serviceaccount -n ${project_name}
oc adm policy add-scc-to-user anyuid -z default -n ${project_name}
```

## License
```
Copyright 2019 Asseco Poland SA

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
