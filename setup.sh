#!/bin/bash
set -Eeuxo pipefail
# This will apply our K8s config for every known component

BASE=./
cd "$BASE"
region="us-east-1"
cluster_prefix="qacluster"
FEATURES="features.${cluster_prefix}"

if [ ! -f "features.${cluster_prefix}" ]; then
    FEATURES="features"
fi

# Get plaintext value from aws secrets
function get_aws_secret_value() {
  echo $(aws secretsmanager get-secret-value --secret-id $1 --query SecretString --output text --region $region)
}

# Start with helm charts - add the repositories first
helm repo add jetstack https://charts.jetstack.io --force-update
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server --force-update
# Update our repo list
helm repo update

# Install the metrics server
if grep -qxc metrics-server $FEATURES; then
    if ! helm status -n kube-system metrics-server; then
        echo 'Installing metrics-server'
        helm upgrade --install metrics-server metrics-server/metrics-server \
          --namespace kube-system \
          --version 3.12.0 \
          --wait --timeout 5m
    fi
fi # metrics-server

if grep -qxc cert-manager $FEATURES; then
    if ! helm status -n cert-manager cert-manager; then
        echo 'Installing cert-manager'
        kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.crds.yaml
        helm upgrade --install cert-manager jetstack/cert-manager \
          --namespace cert-manager \
          --create-namespace \
          --version v1.14.4
    fi
fi # cert-manager
# install clusterissuer
kubectl apply -f $BASE/cert-manager/prod-clusterissuer.yaml