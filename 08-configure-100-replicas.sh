#!/bin/bash

echo "Increasing replicas"
kubectl scale --replicas=100 deployment/nginx-deployment
echo "100 replicas should be created"
kubectl get pods



