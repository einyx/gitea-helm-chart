# Gitea Helm chart
[Gitea](https://gitea.com/) is a lightweight github clone.  This is for those
who wish to self host theri own git repos on kubernetes.

[![License:
MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)![K8](https://img.shields.io/badge/Kubernetes-v1.12-green.svg)


## Introduction

This is a kubernetes helm chart for [Gitea](https://gitea.com/) a lightweight github clone.  It deploys a pod containing containers for the Gitea application along with a Postgresql db for storing application state. It can create peristent volume claims if desired, and also an ingress if the kubernetes cluster supports it.

This chart was developed and tested on kubernetes version 1.12, but should work on earlier or later versions.

## Prerequisites

* [Kubernetes](https://kubernetes.io/) - 😎
* [Helm](https://helm.sh/) - Installer and Dependency Management

## Installing the Chart

To install the chart with the release name `gitea` in the namespace `tools` with the customized values in custom_values.yaml run:

```bash
$ helm install --values custom_values.yaml --name gitea --namespace git helm-gitea
```
or locally:

```bash
$ helm install --name gitea --namewspace tools .
```
> **Tip**: You can use the default [values.yaml](values.yaml)
>

## Configuration

Refer to [values.yaml](values.yaml) for the full run-down on defaults.

The following table lists the configurable parameters of this chart and their default values.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `images.gitea`                    | `gitea` image                     | `gitea/gitea:1.6.1`                                                 |
| `images.imagePullPolicy`          | Image pull policy                               | `Always` if `imageTag` is `latest`, else `IfNotPresent`    |
| `images.imagePullSecrets`         | Image pull secrets                              | `nil`                                                      |
| `ingress.enable`             | Switch to create ingress for this chart deployment                 | `false`                                                 |
| `ingress.useSSL`         | Changes default protocol to SSL?                      | false                                       |
| `ingress.ingress_annotations`          | annotations used by the ingress | `nil`                                                    |
| `service.http.serviceType`         | type of kubernetes services used for http i.e. ClusterIP, NodePort or LoadBalancer                | `ClusterIP`                                                 |
| `service.http.port`       | http port for web traffic                               | `3000`                                                      |
| `service.http.NodePort`            |  Manual NodePort for web traffic                 | `nil`                                                      |
| `service.http.externalPort`           | Port exposed on the internet by a load balancer or firewall that redirects to the ingress or NodePort        | `nil`                                                      |
| `service.http.externalHost`           | IP or DNS name exposed on the internet by a load balancer or firewall that redirects to the ingress or Node for http traffic                       | `nil`                                                      |
| `service.ssh.serviceType`         | type of kubernetes services used for ssh i.e. ClusterIP, NodePort or LoadBalancer                | `ClusterIP`                                                 |
| `service.ssh.port`       | http port for web traffic                               | `22`                                                      |
| `service.ssh.NodePort`            |  Manual NodePort for ssh traffic                 | `nil`                                                      |
| `service.ssh.externalPort`           | Port exposed on the internet by a load balancer or firewall that redirects to the ingress or NodePort        | `nil`                                                      |
| `service.ssh.externalHost`           | IP or DNS name exposed on the internet by a load balancer or firewall that redirects to the ingress or Node for http traffic                                                      |
| `resources.gitea.requests.memory`         | gitea container memory request                             | `100Mi`                                                      |
| `resources.gitea.requests.cpu`      | gitea container request cpu          | `500m`                                            |
| `resources.gitea.limits.memory`    | gitea container memory limits                      | `2Gi`                          |
| `resources.gitea.limits.cpu`                | gitea container CPU/Memory resource requests/limits             | Memory: `1`                               |
| `persistence.enabled`        | Create PVCs to store gitea and postgres data?                | `false`                               |
| `peristence.existingGiteaClaim`    | Already existing PVC that should be used for gitea data.                       | `nil`                                                      |
| `persistence.giteaSize`             | Size of gitea pvc to create                                        | `10Gi`                                                     |
| `persistence.storageClass`         | NStorageClass to use for dynamic provision if not 'default'    | `nil`                                                      |
| `persistence.annotations`    | Annotations to set on created PVCs                           | `nil`                                                    |
| `dbType`             | type of database storage                  | ` "sqllite"`                                                         |
| `externalDB.dbUser`             | external db user                  | ` unset`                                                         |
`externalDB.dbPassword`             | external db password                  | ` unset`                                                         |
`externalDB.dbHost`             | external db host                  | ` unset`                                                         |
`externalDB.dbPort`             | external db port                  | ` unset`                                                         |
`externalDB.dbDatabase`             | external db database name                  | ` unset`                                                         |
| `affinity`                 | Affinity settings for pod assignment            | {}                                                         |
| `tolerations`              | Toleration labels for pod assignment            | []
| `config.offlineMode`              | Sets Gitea's Offline Mode. Values are `true` or `false`.           | `false`
| `config.disableRegistration`     | Disable Gitea's user registration. Values are `true` or `false`.   | `false`
| `config.requireSignin`           | Require Gitea user to be signed in to see any pages. Values are `true` or `false`. | `false`
| `config.openidSignin`            | Allow login with OpenID. Values are `true` or `false`. | `true`

## Usage

Once installed, you can access the application by (hitting a url | executing a command) as follows:

```console
export NODEPORT=`kubectl get svc --selector='app=gitea-gitea,heritage=helm' --output=template --template="{{ with index .items 0}}{{with index .spec.ports 0 }}{{.nodePort}}{{end}}{{end}}"`
export NODE=`kubectl get nodes --output=template --template="{{with index .items 0 }}{{.metadata.name}}{{end}}"`

curl http://$NODE:$NODEPORT
```
--or--

```console 
export PODNAME=`kubectl get pod --selector='app=gitea-gitea,heritage=helm' --output=template --template="{{with index .items 0}}{{.metadata.name}}{{end}}"

kubectl exec $PODNAME command
```

The foo pods can also be scaled:

```console
kubectl scale rc foo --replicas=10
```


### Example custom_values.yaml configs

This configuration creates pvcs with the storageclass glusterfs that cannot be deleted by helm, a kubernetes nginx ingress that serves the web applcation on external dns name git.example.com:8880 and exposes ssh through a NodePort that is exposed externally on a router using port 8022. The external DNS name for ssh is git.example.com.

```yaml
ingress:
  enabled: true
  useSSL: false
  ## annotations used by the ingress - ex for k8s nginx ingress controller:
  ingress_annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "600"
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
    nginx.ingress.kubernetes.io/auth-realm: "Authentication Required - lab2"

service:
  http:
    serviceType: ClusterIP
    port: 3000
    externalPort: 8280
    externalHost: git.example.com
  ssh:
    serviceType: NodePort
    port: 22
    nodePort: 30222
    externalPort: 8022
    externalHost: git.example.com

persistence:
  enabled: true
  giteaSize: 10Gi
  storageClass: glusterfs
  accessMode: ReadWriteMany
  annotations:
    "helm.sh/resource-policy": keep
```


## Uninstalling the Chart

To uninstall/delete the `gitea` deployment:

```bash
$ helm delete gitea --purge
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Data Management

* prevent helm from deleting the pvcs it creates.  Do this by enabling annotation: helm.sh/resource-policy": keep in the pvc optional annotations

```yaml
persistence:
  annotations:
    "helm.sh/resource-policy": keep
```
* create a pvc outside the chart and configure the chart to use it.  Do this by setting the persistence existingGiteaClaim and existingGiteaClaim properties.

```yaml
 existingGiteaClaim: gitea-gitea
```
a trick that can be is used to first set the helm.sh/resource-policy annotation so that the chart generates the pvcs, but doesn't delete them.  Upon next deplyment set the exsiting claim names to the generated values.

## Ingress And External Host/Ports

Gitea requires ports to be exposed for both web and ssh traffic.  The chart is flexible and allow a combination of either ingresses, loadblancer, or nodeport services.

To expose the web application this chart will generate an ingress using the ingress controller of choice if specified. If an ingress is enabled services.http.externalHost must be specified. To expose SSH services it relies on either a LoadBalancer or NodePort.

### Environment Variables
