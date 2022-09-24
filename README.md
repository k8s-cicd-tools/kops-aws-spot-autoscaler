## Kops Aws Spot Autoscaler

This repository shows an example of how to implement in bash all the necessary steps to raise a kubernetes cluster in aws, install and configure the necessary elements to use an autoscaler that works with spot machines.

## How to get started

1. Clone this repo.
2. Create S3 bucket for kops state store. Run `$ ./01-create-S3-bucket.sh`
3. Create the cluster. Run `$ ./02-create-cluster.sh`
4. Labeling nodes. Run `$ ./03-label-as-OnDemand-nodes.sh`
5. Set the spot groups. Run `$ ./04-spot-groups.sh`
6. Install the node termination handler. Run `$ ./05-aws-node-termination-handler.sh`
7. Install the cluster autoscaler. Run `$ ./06-autoscaler.sh`
8. Install the application that will be scaled. Run `$ ./07-deploy-app.sh`
9. Check the pods are running.
10. Scale the deployment. Run `$ ./08-configure-100-replica.sh`
11. Check the pods are running. A new spot group will be created.
12. Scale the deployment. Run `$ ./09-configure-1-replica.sh`
13. Check the pods are running. The new spot group will be deleted.
14. Delete the cluster. Run `$ ./10-delete-cluster.sh`
15. Delete the S3 bucket. Run `$ ./11-delete-S3-bucket.sh`

