# kubernetes-exec-health-probes

Walkthrough using Kubernetes exec health probes for applications without network endpoints.

```bash

# create cluster
k3d cluster create --config k3d.yaml

# view clusters
k3d cluster list

# verify
kubectl get nodes

# delete cluster
k3d cluster delete --config k3d.yaml

```
