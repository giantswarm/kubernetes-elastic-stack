+++
title = "Logging with the Elastic Stack"
description = "The Elastic stack, also known as the ELK stack, has become a wide-spread tool for aggregating logs. This recipe helps you to set it up in Kubernetes."
date = "2017-10-30"
type = "page"
weight = 50
tags = ["recipe"]
+++

# Logging with the Elastic Stack

The Elastic stack, most prominently know as the ELK stack, in this recipe is the combination of Fluentd, Elasticsearch, and Kibana. This stack helps you get all logs from your containers into a single searchable data store without having to worry about logs disappearing together with the containers. With Kibana you get a nice analytics and visualization platform on top.

![Kibana](kibana.png)

## Deploying Elasticsearch, Filebeat, and Kibana

First we create a namespace and deploy our manifests to it.

```bash
kubectl apply \
  --filename https://raw.githubusercontent.com/giantswarm/kubernetes-elastic-stack/master/manifests-all.yaml
```

## Configuring Kibana

Now we need to open up Kibana. As we have no authentication set up in this recipe (you can check out [Shield](https://www.elastic.co/products/x-pack/security) for that), we access Kibana through

```nohighlight
$ POD=$(kubectl get pods --selector component=kibana \
    -o template --template '{{range .items}}{{.metadata.name}} {{.status.phase}}{{"\n"}}{{end}}' \
    | grep Running | head -1 | cut -f1 -d' ')
$ kubectl port-forward --namespace logging $POD 5601:5601
```

Now you can open up your browser at `http://localhost:5601/app/kibana/` and access the Kibana frontend.

Now set `fluentd-*` for `index pattern`.

All set! You can now use Kibana to access your logs including filtering logs based on pod names and namespaces.
