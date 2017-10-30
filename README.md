# Logging with Elastic in Kubernetes

See [docs](docs/index.md) for full recipe content.


# Local Setup

## Start a local Kubernetes using minikube

> If some webpages don't show up immediately wait a bit and reload. Also the Kubernetes Dashboard needs reloading to update its view.

```bash
minikube start --memory 4096
# --vm-driver kvm

minikube dashboard
# maybe wait a bit and retry
kubectl get --all-namespaces services,pods
```

## Logging with Elasticsearch and fluentd

```bash
kubectl apply \
  --filename https://raw.githubusercontent.com/giantswarm/kubernetes-elastic-stack/master/manifests-all.yaml

minikube service kibana
```

For the index pattern in Kibana choose `fluentd-*`, then switch to the "Discover" view.
Every log line by containers running within the Kubernetes cluster is enhenced by metadata like `namespace_name`, `labels` and so on. This way it is easy to group and filter down on specific parts.


## Turn down all logging components

```bash
kubectl delete \
  --filename https://raw.githubusercontent.com/giantswarm/kubernetes-elastic-stack/master/manifests-all.yaml
```

To delete the whole local Kubernetes cluster use this:

```bash
minikube delete
```
