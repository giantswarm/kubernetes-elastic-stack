# Logging with Elastic in Kubernetes

## Start a local Kubernetes using minikube

> If some webpages don't show up immediately wait a bit and reload. Also the Kubernetes Dashboard needs reloading to update its view.

```bash
minikube start --memory 2048
# --vm-driver kvm

minikube dashboard
#^ maybe wait a bit and retry
kubectl get --all-namespaces services,pods
```

## Extra configuration for Elasticsearch and Filebeat

```bash
minikube ssh
sudo sysctl -w vm.max_map_count=262144
cat /proc/sys/vm/max_map_count

sudo echo "EXTRA_ARGS='--label provider=kvm --log-opt labels=io.kubernetes.container.hash,io.kubernetes.container.name,io.kubernetes.pod.name,io.kubernetes.pod.namespace,io.kubernetes.pod.uid'" >> /var/lib/boot2docker/profile

sudo /etc/init.d/docker restart
```

## Logging with Elasticsearch and Filebeat

```bash
kubectl create namespace logging
kubectl --namespace logging create \
  --filename https://raw.githubusercontent.com/giantswarm/kubernetes-elastic-stack/first-draft/manifests-all.yaml
minikube service --namespace logging kibana
  # for index pattern choose `filebeat-*` and ``@timestamp` for Time-field name
```

## Turn down all logging components

```bash
kubectl delete namespace logging
```

To delete the whole local Kubernetes cluster use this:
```bash
minikube delete
```


# How to create one single manifest file

```bash
target="./manifests-all.yaml"
rm "$target"
printf -- "# Derived from ./manifests/*.yaml\n---\n" >> "$target"
for file in ./manifests/*.yaml ; do
  if [ -e "$file" ] ; then
     cat "$file" >> "$target"
     printf -- "---\n" >> "$target"
  fi
done
``
