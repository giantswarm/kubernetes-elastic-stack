#!/bin/sh

test_description="Simple test of a logging setup"

context=${context:-minikube}
debug=${debug:-false}
clear_namespaces=${clear_namespaces:-false}

function log_debug {
  $debug && echo "DEBUG $1" 1>&2
}

function clear_namespaces {
  for namespace in $(kubectl --context "$context" get namespaces --output json | jq -r '.items[] | .metadata.name'); do
    kubectl --context "$context" delete namespace $namespace
  done

  while $(kubectl --context "$context" get namespace logging > /dev/null); do
    echo -n "."
    sleep 0.5
  done
}

function apply_manifests {
  kubectl --context "$context" apply --filename ../manifests
  kubectl --context "$context" apply --filename ../manifests/kibana
  kubectl --context "$context" apply --filename ../manifests/fluent-bit
  kubectl --context "$context" apply --filename ../manifests/fluentd
  kubectl --context "$context" apply --filename ../manifests/filebeat
}

# FIXME! wait for api-server
# check for healthy cluster
# kubectl --context "$context" cluster-info

# maybe only delete "logging" namespace?
$clear_namespaces && clear_namespaces
apply_manifests


elasticsearch_node_ip=$(kubectl --context "$context" --namespace logging \
  get pods --output json \
    | jq -r '.items[] | select(.metadata.labels.component=="elasticsearch")
      | .status.hostIP')

elasticsearch_nodeport=$(kubectl --context "$context" --namespace logging \
  get service elasticsearch --output json \
    | jq '.spec.ports[0].nodePort')


# wait for elasticsearch
echo "wait for elasticsearch to be ready"
$debug && echo "$elasticsearch_node_ip:$elasticsearch_nodeport" 1>&2
while true; do

  es_response=$(curl --request GET --max-time 1 -s "$elasticsearch_node_ip:$elasticsearch_nodeport")
  $debug && echo "$es_response" 1>&2
  tagline=$(echo "$es_response" | jq -r '.tagline')
  if test "You Know, for Search" = "$tagline"; then
    break
  fi
  printf "."
  sleep 0.5
done


echo "testing now"
. ./sharness.sh

# FIXME wait a bit for log lines?
# better: create pod that outputs 1k log lines

test_expect_success "Index for fluent-bit exists" "
    test 1 = $(curl --request GET -sS $elasticsearch_node_ip:$elasticsearch_nodeport/fluent-bit-* \
      | jq '. | length')
"

test_expect_success "Index for fluentd exists" "
    test 1 = $(curl --request GET -sS $elasticsearch_node_ip:$elasticsearch_nodeport/fluentd-* \
      | jq '. | length')
"
test_expect_success "Index for filebeat exists" "
    test 1 = $(curl --request GET -sS $elasticsearch_node_ip:$elasticsearch_nodeport/filebeat-* \
      | jq '. | length')
"

test_expect_success "At least one log-line in fluent-bit" "
    test 0 -lt $(curl --request GET -sS $elasticsearch_node_ip:$elasticsearch_nodeport/fluent-bit-*/_search | jq '.hits.total')
"

test_expect_success "At least one log-line in fluentd" "
    test 0 -lt $(curl --request GET -sS $elasticsearch_node_ip:$elasticsearch_nodeport/fluentd-*/_search | jq '.hits.total')
"

test_expect_success "At least one log-line in filebeat" "
    test 0 -lt $(curl --request GET -sS $elasticsearch_node_ip:$elasticsearch_nodeport/filebeat-*/_search | jq '.hits.total')
"

test_expect_success "More then 1000 log-lines in fluent-bit" "
    test 1000 -lt $(curl --request GET -sS $elasticsearch_node_ip:$elasticsearch_nodeport/fluent-bit-*/_search | jq '.hits.total')
"

test_expect_success "More then 1000 log-lines in fluentd" "
    test 1000 -lt $(curl --request GET -sS $elasticsearch_node_ip:$elasticsearch_nodeport/fluentd-*/_search | jq '.hits.total')
"

test_expect_success "More then 1000 log-lines in filebeat" "
    test 1000 -lt $(curl --request GET -sS $elasticsearch_node_ip:$elasticsearch_nodeport/filebeat-*/_search | jq '.hits.total')
"

# FIXME test if Kibana is up and can connect to Elasticsearch (hint: version mismatch)

test_done
