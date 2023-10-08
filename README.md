# kubernetes-exec-health-probes

Sample of how to use Kubernetes exec health probes for workloads that do not have HTTP endpoints.

## Setup

The repository has a devcontainer that is configured with the tools required to follow this sample. To follow along without the devcontainer, install the tools listed below.

- Docker - <https://docs.docker.com/get-docker/>
- k3d - <https://k3d.io/#installation>
- kubectl - <https://kubernetes.io/docs/tasks/tools/#kubectl>

## Purpose

Kubernetes container probes enable you to conduct regular diagnostics on a container. The results of these probes influence Kubernetes' actions to maintain a healthy workload.

This sample repository demonstrates the use of the `exec` probe in a situation where the container's workload lacks a network endpoint capable of receiving network traffic. This is simulated using a basic shell script that continuously updates a single file.

The underlying assumption is that there exists a method to determine that the workload remains active and is not in a deadlock state. Example indicators could be a regularly updated log file, a database entry, or a message within a queue – any signal that signifies the workload has performed some action since the last diagnostic.

More information on probes can be found here, <https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes>.

## Walkthrough

Create a local cluster using k3d. the k3d.yaml config file includes a local registry as well.

```bash

# create cluster with attached local registry
k3d cluster create --config k3d.yaml

# view clusters
k3d cluster list

# verify
kubectl get nodes

```

Build the container image for the sample workload and push to the local k3d registry.

```bash

# build and tag container image
docker build . -t k3d-registry.localhost:5000/k8s-exec-probe-demo

# push to local registry
docker push k3d-registry.localhost:5000/k8s-exec-probe-demo

```

Create two deployments. One of the deployments, `deploy-fail.yaml`, is configured to fail the liveness probe.

The script representing our sample workload is configured to only update its file every 60 seconds.

```yaml
# deploy-fail.yaml
...
        args:
          - "60"
...
```

The liveness probe is configured to check every 10 seconds, if a specific file has been update in the last 10 seconds. Since it'll take a minute for the target file to be updated, the probe will eventually fail, causing a pod restart.

```yaml
# deploy-fail.yaml
...
        livenessProbe:
          exec:
            command:
              - "./liveness.sh"
              - "10"
              - "/tmp/health.txt"
          initialDelaySeconds: 5
          periodSeconds: 10
...
```

Apply the deployments and wait for one of them to restart.

```bash

# deploy
kubectl apply -f deploy.yaml
kubectl apply -f deploy-fail.yaml

# view pods and pod restarts
# it might take a minute or two to see the pod restarts
kubectl get pods

```

When restarts start to show up, view the messages in the Kubernetes events.

```bash

# get failing pods name
podName=$(kubectl get pods -l app=k8s-exec-probe-demo-fail -o jsonpath='{.items[0].metadata.name}')

# view pod events
kubectl get events --field-selector "involvedObject.name=$podName"

# view messages from the events
kubectl get events --field-selector "involvedObject.name=$podName" -o jsonpath="{.items[*].message}"

```

## Clean up

```bash

# delete cluster
k3d cluster delete --config k3d.yaml

```
