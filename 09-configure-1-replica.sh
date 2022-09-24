#!/bin/bash

echo "Increasing replicas"
kubectl scale --replicas=1 deployment/nginx-deployment
echo "1 replicas should be created"
kubectl get pods



