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

# get failing pods name
podName=$(kubectl get pods -l app=k8s-exec-probe-demo-fail -o jsonpath='{.items[0].metadata.name}')

# view probe status and messages in the events
kubectl get events --field-selector "involvedObject.name=$podName"

# delete cluster
k3d cluster delete --config k3d.yaml

```
