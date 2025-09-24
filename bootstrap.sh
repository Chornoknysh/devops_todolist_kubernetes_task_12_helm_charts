#!/usr/bin/env bash
set -euo pipefail

# 1. Create kind cluster
kind create cluster --config .infrastructure/cluster.yml

# wait for nodes ready
kubectl wait --for=condition=Ready node --all --timeout=120s

# 2. Inspect nodes for labels
echo "=== Nodes and labels ==="
kubectl get nodes --show-labels

# 3. Label nodes (example: label the first worker node app=mysql)
# Find a node without control-plane role to label
NODE_TO_LABEL=$(kubectl get nodes -o name | grep -v control-plane | head -n1 | sed 's|node/||')
if [ -n "$NODE_TO_LABEL" ]; then
  kubectl label node "$NODE_TO_LABEL" app=mysql --overwrite
  echo "Labeled node $NODE_TO_LABEL with app=mysql"
  # 4. Taint the node
  kubectl taint node "$NODE_TO_LABEL" app=mysql:NoSchedule --overwrite
  echo "Tainted node $NODE_TO_LABEL app=mysql:NoSchedule"
else
  echo "No suitable node found to label"
fi

# 5. Prepare helm chart
cd helm-chart/todoapp
helm dependency update
cd -

# 6. Install the chart (namespace from values)
helm upgrade --install todoapp ./helm-chart/todoapp --create-namespace --namespace "$(yq e '.namespace' helm-chart/todoapp/values.yaml)"

# 7. Wait for resources (basic wait)
kubectl wait --for=condition=available deployment -l app.kubernetes.io/name=todoapp --namespace "$(yq e '.namespace' helm-chart/todoapp/values.yaml)" --timeout=120s || true

# 8. Output cluster resources to output.log in repo root
kubectl get all,cm,secret,ing -A > output.log

echo "Deployment finished. output.log created."
