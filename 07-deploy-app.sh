#!/bin/bash

echo "Installing test app"
kubectl apply -f https://k8s.io/examples/application/deployment.yaml
kubectl get deployment.app/nginx-deployment
kubectl get pods
kubectl scale --replicas=20 deployment/nginx-deployment
echo "20 replicas should be created"
kubectl get pods



