# Logging with Elastic in Kubernetes

See [docs](docs/index.md) for full recipe content.


This setup is similar to the [`Full Stack Example`](https://github.com/elastic/examples/tree/master/Miscellaneous/docker/full_stack_example), but adopted to be run on a Kubernetes cluster.

There is no access control for the Kibana web interface. If you want to run this in public you need to secure your setup. The provided manifests here are for demonstration purposes only.


# Local Setup

## Start a local Kubernetes using minikube

> If some webpages don't show up immediately wait a bit and reload. Also the Kubernetes Dashboard needs reloading to update its view.

```bash
minikube start --memory 4096

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
Every log line by containers running within the Kubernetes cluster is enhanced by meta data like `namespace_name`, `labels` and so on. This way it is easy to group and filter down on specific parts.


## Turn down all logging components

```bash
kubectl delete \
  --filename https://raw.githubusercontent.com/giantswarm/kubernetes-elastic-stack/master/manifests-all.yaml
```

FIXME alternatively
--selector stack=logging

To delete the whole local Kubernetes cluster use this:

```bash
minikube delete
```
