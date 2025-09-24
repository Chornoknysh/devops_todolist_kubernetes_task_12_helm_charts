# Instructions to Validate the Helm Chart Deployment

This document explains how to validate that the `todoapp` Helm chart and its `mysql` sub-chart are correctly deployed to the kind cluster.

---

## 1. Bootstrap the Cluster

Run the bootstrap script to set up the cluster, namespaces, RBAC, and Helm charts:

chmod +x bootstrap.sh
./bootstrap.sh
This will:

Create the kind cluster from cluster.yml

Apply necessary taints on nodes with label app=mysql

Deploy the todoapp Helm chart with the mysql dependency

2. Verify Namespaces
Ensure that the namespaces from values.yaml are created:


kubectl get ns
Expected:

todoapp namespace

mysql namespace

3. Verify Deployments and StatefulSets
Check the todoapp Deployment:

kubectl get deploy -n todoapp
Check the mysql StatefulSet:

kubectl get sts -n mysql
4. Verify Secrets
Secrets are created from values.yaml using a range function. Validate them:


kubectl get secrets -n todoapp
kubectl get secrets -n mysql
5. Verify Configurations
Check Resource Requests and Limits

kubectl get deploy todoapp -n todoapp -o yaml | grep resources -A5
Check Rolling Update Strategy

kubectl get deploy todoapp -n todoapp -o yaml | grep rollingUpdate -A5
Check HPA

kubectl get hpa -n todoapp
Check PV and PVC

kubectl get pv
kubectl get pvc -n todoapp
kubectl get pvc -n mysql
6. Verify Node Affinity and Tolerations
Check Deployment affinity:


kubectl describe deploy todoapp -n todoapp | grep -A5 Affinity
Check StatefulSet tolerations:


kubectl describe sts mysql -n mysql | grep -A5 Tolerations
7. Final Validation
Run the following command to list all deployed resources:


kubectl get all,cm,secret,ing -A
Save the output into a file:

kubectl get all,cm,secret,ing -A > output.log
Attach the file to your PR.

✅ Validation is complete once:

All namespaces exist

Deployments and StatefulSets are running

Secrets are created and mounted as env variables

HPA, PV, PVC, affinity, tolerations, and rolling updates match values.yaml

The output.log file is present in the repository root