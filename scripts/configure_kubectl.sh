#!/bin/bash
set -euo pipefail

CLUSTER_NAME=${1:?cluster name is required}
REGION=${2:?region is required}

aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"
kubectl get nodes
