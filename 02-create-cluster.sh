#!/bin/bash
#https://aws.amazon.com/es/getting-started/hands-on/run-kops-kubernetes-clusters-for-less-with-amazon-ec2-spot-instances/

source 00-envs.sh
echo "Kubernetes version: ${KUBECTL_VERSION}"
echo "Kubectl version: ${KUBECTL_VERSION}"
echo "Kops version: ${KOPS_VERSION}"
echo "Creating cluster ${NAME}"
kops create cluster \
--name ${NAME} \
--state ${KOPS_STATE_STORE} \
--cloud aws \
--master-size t3.medium \
--master-count 1 \
--master-zones ${AWS_REGION_AZS} \
--zones ${AWS_REGION_AZS} \
--node-size t3.medium \
--node-count 2 \
--dns private \
--kubernetes-version ${KUBECTL_VERSION}

#Suggestions:
# * list clusters with: kops get cluster
# * edit this cluster with: kops edit cluster myfirstcluster.k8s.local
# * edit your node instance group: kops edit ig --name=myfirstcluster.k8s.local nodes
# * edit your master instance group: kops edit ig --name=myfirstcluster.k8s.local master-us-west-1b
#
#Finally configure your cluster with: kops update cluster --name myfirstcluster.k8s.local --yes

kops update cluster ${NAME} --yes
kops export kubecfg --admin
kops validate cluster --wait 10m
