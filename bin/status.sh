#!/bin/bash

set -eu

readonly dir=$(dirname $(dirname "$0"))

export KUBECONFIG=$dir/artifacts/k0s-kubeconfig.yaml
set -x
kubectl get pvc -A
kubectl get pv
kubectl get sts -A
kubectl get deploy -A
kubectl get ds -A
kubectl get vm -A
kubectl get vmi -A
kubectl get pod -A