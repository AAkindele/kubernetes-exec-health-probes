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

### Create local cluster

Create a local cluster using k3d. The k3d.yaml config file includes a local registry as well.

```bash

# create cluster with attached local registry
k3d cluster create --config k3d.yaml

# view clusters
k3d cluster list

### example output
# NAME              SERVERS   AGENTS   LOADBALANCER
# k8s-exec-probes   1/1       1/1      true

# verify
kubectl get nodes

### example output
# NAME                           STATUS   ROLES                  AGE    VERSION
# k3d-k8s-exec-probes-server-0   Ready    control-plane,master   114s   v1.27.4+k3s1
# k3d-k8s-exec-probes-agent-0    Ready    <none>                 109s   v1.27.4+k3s1

```

### Build container image

Build the container image for the sample workload and push to the local k3d registry.

```bash

# build and tag container image
docker build . -t k3d-registry.localhost:5000/k8s-exec-probe-demo

# push to local registry
docker push k3d-registry.localhost:5000/k8s-exec-probe-demo

```

### Deploy sample workloads

Create two deployments. The first deployment, `deploy.yaml`, is configured to be stable. The second, `deploy-fail.yaml`, is configured to fail the liveness probe.

`deploy-fail.yaml` simulates the scenario where the workload is not progressing at our expected rate. In this scenario, the workload is intentionally configured to take longer than expected to update the file we're checking in the probe.

```yaml
# deploy-fail.yaml
...
        args:
          - "60"
...
```

The liveness probe is configured to check every 10 seconds, if a specific file has been update in the last 10 seconds. Since it'll take a 60 seconds for the target file to be updated, the probe will eventually fail, causing a pod restart.

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

###example output
# NAME                                        READY   STATUS    RESTARTS     AGE
# k8s-exec-probe-demo-65f489d567-n9hw7        1/1     Running   0            79s
# k8s-exec-probe-demo-fail-58bdbf5445-2m4pb   1/1     Running   1 (8s ago)   79s

```

### View probe events and messages

When restarts start to show up, view the messages in the Kubernetes events.

```bash

# get failing pods name
podName=$(kubectl get pods -l app=k8s-exec-probe-demo-fail -o jsonpath='{.items[0].metadata.name}')

# view pod events
kubectl get events --field-selector "involvedObject.name=$podName"

###example output
# LAST SEEN   TYPE      REASON      OBJECT                                          MESSAGE
# 2m8s        Normal    Scheduled   pod/k8s-exec-probe-demo-fail-58bdbf5445-2m4pb   Successfully assigned default/k8s-exec-probe-demo-fail-58bdbf5445-2m4pb to k3d-k8s-exec-probes-agent-0
# 2m7s        Normal    Pulled      pod/k8s-exec-probe-demo-fail-58bdbf5445-2m4pb   Successfully pulled image "k3d-registry.localhost:5000/k8s-exec-probe-demo" in 725.692522ms (725.753475ms including waiting)
# 108s        Warning   Unhealthy   pod/k8s-exec-probe-demo-fail-58bdbf5445-2m4pb   Liveness probe failed: threshold_seconds - 10...
# 98s         Warning   Unhealthy   pod/k8s-exec-probe-demo-fail-58bdbf5445-2m4pb   Liveness probe failed: threshold_seconds - 10...
# 88s         Warning   Unhealthy   pod/k8s-exec-probe-demo-fail-58bdbf5445-2m4pb   Liveness probe failed: threshold_seconds - 10...

# view messages from the events
kubectl get events --field-selector "involvedObject.name=$podName" -o jsonpath="{.items[*].message}"

```

## Clean up

```bash

# delete cluster
k3d cluster delete --config k3d.yaml

```
