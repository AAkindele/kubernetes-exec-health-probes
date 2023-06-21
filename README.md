# kubernetes-exec-health-probes

Walkthrough using Kubernetes exec health probes for applications without network endpoints.

Tested on:

- docker version 24.0.2
- k3d version 5.5.1

```bash

# create cluster
k3d cluster create --config k3d.yaml

# view clusters
k3d cluster list

# verify
kubectl get nodes

# docker build
docker build . -t k3d-registry.localhost:5000/k8s-exec-probe-demo

# push
docker push k3d-registry.localhost:5000/k8s-exec-probe-demo

# deploy
kubectl apply -f deploy.yaml
kubectl apply -f deploy-fail.yaml

# view pods and pod restarts
kubectl get pods

# view probe status in events
# TODO: view events for a specific pod from `kubectl get events`
kubectl describe pod <pod name>

# delete cluster
k3d cluster delete --config k3d.yaml

```
