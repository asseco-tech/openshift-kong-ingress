# openshift-kong-ingress
OpenShift Deployment for Kong API Gateway Ingress Controller and Konga GUI.

Repository address: https://github.com/asseco-tech/openshift-kong-ingress/

## Content
It is OpenShift edition of [Kong for Kubernetes](https://github.com/Kong/kubernetes-ingress-controller) scripts and 
[Konga GUI Deployment](https://github.com/pantsel/konga).
Added some permission objects and converted to OpenShift specific objects.

## Compatiblity
**openshift-kong-ingress** has tested with:
 - OpenShift 3.11
 - Kong 1.4
 - Kong Controller 0.6.2
 
## Automated Installing
Configuring in:
```
configure.env
```
Running scripts:
```
cd deploy
    . install-admin.sh
    . install.sh
```  
Script `install-admin.sh` require Cluster-Admin role.   
Script `install.sh` require only Project Edit role.

## Manually Installing
You can use `*.yaml` templates (look at deploy folder) and install them in the order below:

| Template                     | Required Role |
|------------------------------|---------------|
| kong-cluster-template.yaml   | cluster-admin |
| kong-namespace-template.yaml | cluster-admin |
| kong-account-template.yaml   | cluster-admin |
| kong-controller-template.yaml| edit |
| konga-ui-template.yaml       | edit |

Every template has parameters with some documentation inside.

## License
**openshift-kong-ingress** is published under [Apache License 2.0](LICENSE).
