## Kops Aws Spot Autoscaler

This repository shows an example of how to implement in bash all the necessary steps to raise a kubernetes cluster in aws, install and configure the necessary elements to use an autoscaler that works with spot machines.

Includes a Dockerfile that generates an image with all the necessary libraries to run the scripts

## Requirements

clone this repository and compile the docker image with the following command:
```
docker build -t aws-kops .
```
start the container with the following command:
```
docker-compose up -d
```
access the container with the following command:
```
docker exec -it aws-kops /bin/bash
```
check that the aws credentials are configured correctly in ~/.aws folder, if not, configure them and check that the credentials are correct with the following command:
```
aws sts get-caller-identity
```

You already have the environment ready to continue.

## How to get started

1. Enter the folder where the scripts are located: `cd koops-aws-spot-autoscaler` and execute `chmod +x *.sh` to give execution permissions to the scripts.c
2. Create S3 bucket for kops state store. Run `$ ./01-create-S3-bucket.sh`
3. Create the cluster. Run `$ ./02-create-cluster.sh`
4. Labeling nodes. Run `$ ./03-label-as-OnDemand-nodes.sh`
5. Set the spot groups. Run `$ ./04-spot-groups.sh`
6. Install the node termination handler. Run `$ ./05-aws-node-termination-handler.sh`
```
$ kubectl get deployment aws-node-termination-handler -n kube-system -o wide
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS                     
aws-node-termination-handler   1/1     1            1           13s   aws-node-termination-handler
```
7. Install the cluster autoscaler. Run `$ ./06-autoscaler.sh`
```
$ kubectl --namespace=default get pods -l "app.kubernetes.io/name=aws-cluster-autoscaler,app.kubernetes.io/instance=cluster-autoscaler-${AUTO_SCALER_VERSION}"
NAME                                  READY   STATUS    RESTARTS   AGE
cluster-autoscaler-7bb544c857-xwtbx   1/1     Running   0          5s
```
8. Install the application that will be scaled. Run `$ ./07-deploy-app-20-replicas.sh`
9. Check the pods and nodes are running.
```
$ kubectl get pods -l app=nginx
NAME                                  READY   STATUS    RESTARTS   AGE
nginx-deployment-66b6c48dd5-25zm9     1/1     Running   0          32s
nginx-deployment-66b6c48dd5-44mnb     1/1     Running   0          32s
nginx-deployment-66b6c48dd5-4vwqj     1/1     Running   0          32s
... 16 more ...
nginx-deployment-66b6c48dd5-zzq9w     1/1     Running   0          32s

$ kubectl get nodes
NAME                            STATUS   ROLES                  AGE     VERSION
ip-172-20-46-58.ec2.internal    Ready    node,spot-worker       12m     v1.21.0
ip-172-20-49-42.ec2.internal    Ready    node,spot-worker       8m49s   v1.21.0
ip-172-20-51-240.ec2.internal   Ready    node                   15m     v1.21.0
ip-172-20-56-118.ec2.internal   Ready    control-plane,master   24m     v1.21.0
ip-172-20-63-2.ec2.internal     Ready    node                   20m     v1.21.0
```
10. Scale the deployment. Run `$ ./08-configure-100-replicas.sh` and wait until the pods are running.
```
$ kubectl get pods -l app=nginx
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-66b6c48dd5-25zm9   1/1     Running   0          9m16s
nginx-deployment-66b6c48dd5-26jlp   1/1     Running   0          2m42s
nginx-deployment-66b6c48dd5-2hcww   1/1     Running   0          2m42s
... 96 more ...
nginx-deployment-66b6c48dd5-2lxxj   1/1     Running   0          2m42s
```
11. Check the pods are running. A new "node,spot-worker" will be created.
```
$ kubectl get nodes
NAME                            STATUS   ROLES                  AGE   VERSION
ip-172-20-42-128.ec2.internal   Ready    node,spot-worker       28s   v1.21.0
ip-172-20-46-58.ec2.internal    Ready    node,spot-worker       17m   v1.21.0
ip-172-20-49-42.ec2.internal    Ready    node,spot-worker       13m   v1.21.0
ip-172-20-51-240.ec2.internal   Ready    node                   20m   v1.21.0
ip-172-20-56-118.ec2.internal   Ready    control-plane,master   29m   v1.21.0
ip-172-20-63-2.ec2.internal     Ready    node                   25m   v1.21.0
```
12. Scale the deployment. Run `$ ./09-configure-1-replica.sh`
```
$ kubectl get pods -l app=nginx
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-66b6c48dd5-7pk47   1/1     Running   0          5m20s
```
13. Check the pods are running. The new "node,spot-worker" will be deleted, waiting a 10 minutes to be sure that the node is deleted.
```
$ kubectl get nodes
NAME                            STATUS                     ROLES                  AGE     VERSION
ip-172-20-42-128.ec2.internal   NotReady,SchedulingDisabled   node,spot-worker       7m54s   v1.21.0
ip-172-20-46-58.ec2.internal    Ready                      node,spot-worker       24m     v1.21.0
ip-172-20-49-42.ec2.internal    Ready                      node,spot-worker       21m     v1.21.0
ip-172-20-51-240.ec2.internal   Ready                      node                   27m     v1.21.0
ip-172-20-56-118.ec2.internal   Ready                      control-plane,master   37m     v1.21.0
ip-172-20-63-2.ec2.internal     Ready                      node                   32m     v1.21.0

a few minutes later...

$ kubectl get nodes
NAME                            STATUS   ROLES                  AGE   VERSION
ip-172-20-46-58.ec2.internal    Ready    node,spot-worker       26m   v1.21.0
ip-172-20-49-42.ec2.internal    Ready    node,spot-worker       23m   v1.21.0
ip-172-20-51-240.ec2.internal   Ready    node                   29m   v1.21.0
ip-172-20-56-118.ec2.internal   Ready    control-plane,master   39m   v1.21.0
ip-172-20-63-2.ec2.internal     Ready    node                   34m   v1.21.0
```
14. Delete the cluster. Run `$ ./10-delete-cluster.sh`
15. Delete the S3 bucket. Run `$ ./11-delete-S3-bucket.sh`

