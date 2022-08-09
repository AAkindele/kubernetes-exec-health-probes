# kubernetes-exec-health-probes

Walkthrough using Kubernetes exec health probes for applications without network endpoints.

docker version 20.10.17
k3d version 5.4.4

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

# delete cluster
k3d cluster delete --config k3d.yaml

```
