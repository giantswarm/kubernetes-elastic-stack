# Logging with Elastic in Kubernetes

See [docs](docs/index.md) for full recipe content.

# Local Setup

## Start a local Kubernetes using minikube

> If some webpages don't show up immediately wait a bit and reload. Also the Kubernetes Dashboard needs reloading to update its view.

```bash
minikube start
# --vm-driver kvm

minikube dashboard
# maybe wait a bit and retry
kubectl get --all-namespaces services,pods
```

## Extra configuration for Elasticsearch and Filebeat

```bash
minikube ssh

sudo sh -c "sed -i 's/^ExecStart=\/usr\/bin\/docker daemon.*$/& --log-opt labels=io.kubernetes.container.hash,io.kubernetes.container.name,io.kubernetes.pod.name,io.kubernetes.pod.namespace,io.kubernetes.pod.uid/' /etc/systemd/system/docker.service"

sudo systemctl daemon-reload
sudo systemctl restart docker.service
```

## Logging with Elasticsearch and Filebeat

```bash
kubectl apply \
  --filename https://raw.githubusercontent.com/giantswarm/kubernetes-elastic-stack/master/manifests-all.yaml
minikube service --namespace logging kibana
  # for index pattern choose `filebeat-*` and `@json.time` for Time-field name
```

## Turn down all logging components

```bash
kubectl delete namespace logging
```

To delete the whole local Kubernetes cluster use this:

```bash
minikube delete
```
