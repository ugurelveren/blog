---
title: "Kubernetes Resources"
date: "2026-02-15"
slug: "kubernetes-resources"
description: "Short guide to core Kubernetes resources: Pods, Deployments, StatefulSets, DaemonSets, Jobs and CronJobs."
categories: ["technical","kubernetes"]
tags: ["kubernetes","resources","workloads"]
author: "Ugur Elveren"
series: "KCNA"
toc: true
reading_time: 6
layout: "post"
---

Now that we have defined Kubernetes and reviewed its history, let us look at Kubernetes resources. Kubernetes resources are the basic building blocks that represent the desired state of the cluster. You can think of them as objects stored in the Kubernetes API. There are many types of Kubernetes objects. They describe which containerized applications run, what resources those applications can use, and the policies that control their behavior.

Resources can be grouped in different ways. A useful approach is to group them by function.

## Workload and Compute Resources

This group covers compute resources such as Pod, Deployment, StatefulSet, DaemonSet, Job and CronJob. Each resource has a different responsibility. I will describe them one by one and explain what they do.

### Pod

A Pod is the smallest deployable unit in Kubernetes. It represents a single instance of a running process in the cluster. A Pod can contain multiple containers that share the same network namespace, IP address and storage volumes.

Pods are created, scheduled and removed as a single entity. They can share volumes and run on one node only. Pods are ephemeral; when a Pod ends it does not keep the same identity.

**Important**: In production you should rarely create Pods directly. Use higher level resources such as Deployments or StatefulSets to manage Pods for you.

Single container pod example

``` yml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    ports:
    - containerPort: 80
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"

```

#### kubectl — Quick Pod Examples

Below are common `kubectl` commands you can use with the `nginx-pod` example. each command has an inline comment explaining what it does.

```bash
# create or update the Pod from a manifest file (create if missing, update if exists)
kubectl apply -f pod.yaml

# list Pods in the current namespace (shows status)
kubectl get pods

# show node, IP and other wide info for the specific Pod
kubectl get pod nginx-pod -o wide

# show detailed state and recent events for troubleshooting
kubectl describe pod nginx-pod

# fetch container logs (use -f to stream)
kubectl logs nginx-pod

# open an interactive shell inside the Pod's main container
kubectl exec -it nginx-pod -- /bin/sh

# forward local port 8080 to Pod port 80 for local testing
kubectl port-forward pod/nginx-pod 8080:80

# delete the Pod (note: controllers will recreate Pods they manage)
kubectl delete pod nginx-pod

# wait until the Pod is Ready (useful in scripts)
kubectl wait --for=condition=ready pod/nginx-pod --timeout=60s
```

> Tip: inline comments above explain purpose — use `kubectl --help` or `kubectl <command> -h` for flags and additional options.

### Deployment

A Deployment is the most common workload resource in Kubernetes. It gives declarative updates for Pods and ReplicaSets, and it is a good choice for stateless applications. It handles rolling updates, rollbacks, scaling, and self healing.

Kubernetes works with a desired state model. You describe what you want, and Kubernetes works to keep that state. By default, Deployments use rolling updates, so Pods are replaced step by step with little or no downtime. Deployments also keep revision history for rollbacks, replace failed Pods, and let you change replica count.

``` yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"

```

#### kubectl — Quick Deployment Examples

A few common `kubectl` commands for `nginx-deployment` with short inline explanations.

```bash
# create or update the Deployment from a manifest
kubectl apply -f deployment.yaml

# list Deployments in the current namespace
kubectl get deployments

# show pods that belong to this Deployment (label selector)
kubectl get pods -l app=nginx

# show rollout status (waits until the Deployment has finished updating)
kubectl rollout status deployment/nginx-deployment

# view rollout history and revisions
kubectl rollout history deployment/nginx-deployment

# rollback to the previous revision
kubectl rollout undo deployment/nginx-deployment

# perform a live rolling update (change image)
kubectl set image deployment/nginx-deployment nginx=nginx:1.22

# scale Deployment replicas
kubectl scale deployment/nginx-deployment --replicas=5

# inspect Deployment details and recent events
kubectl describe deployment nginx-deployment

# delete the Deployment (its Pods will be removed)
kubectl delete deployment nginx-deployment
```

> Tip: use `kubectl rollout status` in CI/scripts to wait for a successful deployment.

#### Deployment strategies

There are several deployment strategies. Two common strategies that Kubernetes supports by default are rolling updates and recreate. Other strategies usually need extra tools or custom setup.

* **rolling updates**
  Rolling updates replace old Pods with new Pods in small steps. The controller creates new Pods, waits until they are ready, and then removes old Pods. This helps reduce downtime.

* **recreate**
  The recreate strategy removes all current Pods before it creates new Pods. This strategy is simple, but it causes downtime while new Pods start.

### StatefulSet

A StatefulSet is a workload resource for stateful applications. Use it when an application needs stable network identity, stable persistent storage, and ordered deployment or scaling. Unlike Deployments, Pods in a StatefulSet keep stable identities across rescheduling.

A StatefulSet gives each Pod a stable network identity with a predictable hostname and DNS record, so the Pod keeps the same name after restarts. Each Pod also gets its own `PersistentVolumeClaim` for storage that stays even if the Pod is rescheduled. Pods are created one at a time in order, and when scaling down, Pods are removed in reverse order. Updates to Pods happen in order, starting from the highest number to the lowest.

``` yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "web-service"  # Required: Headless service for network identity
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  
  # Volume Claim Template - each Pod gets its own PVC
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "standard"
      resources:
        requests:
          storage: 1Gi

```

#### kubectl — Quick StatefulSet Examples

Commands and short explanations for the `web` StatefulSet from the example above.

```bash
# apply the StatefulSet manifest (create or update)
kubectl apply -f statefulset.yaml

# list StatefulSets (shows desired/ready replicas)
kubectl get statefulset

# inspect pods created by the StatefulSet (ordered names: web-0, web-1 ...)
kubectl get pods -l app=web

# show detailed status/events for a specific pod (useful for troubleshooting)
kubectl describe pod web-0

# show StatefulSet resource (full YAML/status)
kubectl get statefulset web -o yaml

# scale StatefulSet (respect the ordered nature of pods)
kubectl scale statefulset web --replicas=5

# delete a single Pod (StatefulSet controller will recreate it preserving identity)
kubectl delete pod web-2

# delete StatefulSet but keep PVCs (useful when you want to preserve storage)
kubectl delete statefulset web --cascade=false

# change container image to trigger a rolling update (StatefulSet updateStrategy must allow rolling updates)
kubectl set image statefulset/web nginx=nginx:1.22

# list PersistentVolumeClaims created from the volumeClaimTemplates
kubectl get pvc -l app=web

# exec into the first Pod (ordinal 0)
kubectl exec -it web-0 -- /bin/sh

# forward local port 8080 to a Pod port for testing
kubectl port-forward pod/web-0 8080:80

# wait until all StatefulSet pods are Ready (useful in automation)
kubectl wait --for=condition=ready pod -l app=web --timeout=120s
```

> Tip: StatefulSet Pods have stable identities (web-0, web-1, ...). Deleting a StatefulSet with `--cascade=false` preserves PVCs so data is not lost.

#### StatefulSet vs Deployment

| Feature | StatefulSet | Deployment |
|---------|-------------|------------|
| **Pod Identity** | Stable, predictable (web0, web1) | Random (webabc123) |
| **Pod Order** | Sequential creation/deletion | Parallel |
| **Storage** | Persistent per Pod | Shared or ephemeral |
| **Network ID** | Stable hostname | Random hostname |
| **Use Case** | Stateful apps (databases) | Stateless apps (web servers) |
| **Scaling** | Ordered | Parallel |

### DaemonSet

A DaemonSet ensures that a copy of a Pod runs on every node, or on a selected group of nodes. When new nodes join the cluster, it adds Pods to those nodes. When nodes leave, Kubernetes removes those Pods. DaemonSets are useful for node level services such as log collection and monitoring agents.

``` yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
  namespace: kube-system
  labels:
    app: fluentd
spec:
  selector:
    matchLabels:
      app: fluentd
  template:
    metadata:
      labels:
        app: fluentd
    spec:
      containers:
      - name: fluentd
        image: fluentd:v1.14
        resources:
          limits:
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 200Mi
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
      
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers

```

#### kubectl — Quick DaemonSet Examples

Useful `kubectl` commands for the `fluentd` DaemonSet (namespace: `kube-system`). Inline comments explain each command.

```bash
# apply the DaemonSet manifest (create or update)
kubectl apply -f daemonset.yaml -n kube-system

# list DaemonSets in the namespace
kubectl get daemonset -n kube-system

# list Pods created by the DaemonSet (shows node placement)
kubectl get pods -n kube-system -l app=fluentd -o wide

# show detailed status and events for the DaemonSet
kubectl describe daemonset fluentd -n kube-system

# fetch logs from a DaemonSet Pod (replace POD with actual pod name)
kubectl logs POD -n kube-system

# delete a single Pod (the DaemonSet controller will recreate it)
kubectl delete pod <pod-name> -n kube-system

# update container image across the DaemonSet
kubectl set image daemonset/fluentd fluentd=fluentd:v1.15 -n kube-system

# drain a node for maintenance (DaemonSet Pods are ignored by default)
kubectl drain <node-name> --ignore-daemonsets --delete-local-data

# cordon/uncordon a node to prevent/allow scheduling
kubectl cordon <node-name>
kubectl uncordon <node-name>

# delete the DaemonSet (use --cascade to remove Pods)
kubectl delete daemonset fluentd -n kube-system
```

> Tip: DaemonSets run on (most) nodes — use nodeSelectors, nodeAffinity or taints to limit where they run.

### Job

A Job runs work until it is complete. It creates one or more Pods and ensures that the required number of Pods finish successfully. Unlike Deployments, Jobs do not keep Pods running forever. Use Jobs for batch processing and one time tasks. The Job spec controls retries and parallel execution.

``` yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi-calculation
spec:
  template:
    spec:
      containers:
      - name: pi
        image: perl:5.34
        command: ["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never  # Never or OnFailure (not Always)
  
  backoffLimit: 4  # Number of retries before considering Job failed

```

#### kubectl — Quick Job Examples

Common commands for managing and troubleshooting `Job` resources.

```bash
# create or update the Job from a manifest
kubectl apply -f job.yaml

# list Jobs in the current namespace
kubectl get jobs

# list Pods created by the Job (Pods get label job-name=<job-name>)
kubectl get pods -l job-name=pi-calculation

# show Job details and events
kubectl describe job pi-calculation

# fetch logs from the Job's Pod (replace POD with actual pod name)
kubectl logs POD

# wait for Job to complete (useful in automation)
kubectl wait --for=condition=complete job/pi-calculation --timeout=300s

# delete the Job (this will remove the Job object and its Pods)
kubectl delete job pi-calculation
```

> Tip: use `backoffLimit`, `completions` and `parallelism` in Job specs to control retries and concurrency.

### CronJob

A CronJob runs Jobs on a repeating schedule with cron syntax. It is the Kubernetes equivalent of Unix cron and is useful for periodic tasks such as backups, report generation, and cleanup.

Each scheduled run creates a new Job object. The controller keeps history for succeeded and failed Jobs based on your settings. CronJobs also support concurrency control to avoid overlapping runs. Recent Kubernetes versions also support optional timezone settings for schedules.

``` yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello-world
spec:
  schedule: "*/5 * * * *"  # Every 5 minutes
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox:1.35
            command:
            - /bin/sh
            - -c
            - date; echo "Hello from Kubernetes CronJob"
          restartPolicy: OnFailure

```

#### kubectl — Quick CronJob Examples

Practical `kubectl` commands to inspect, trigger and manage CronJobs.

```bash
# create or update the CronJob from a manifest
kubectl apply -f cronjob.yaml

# list CronJobs
kubectl get cronjob

# show CronJob details (schedule, suspend, history limits)
kubectl describe cronjob hello-world

# list Jobs created by CronJobs (look for names starting with the CronJob name)
kubectl get jobs --sort-by=.metadata.creationTimestamp

# manually trigger a run from the CronJob
kubectl create job --from=cronjob/hello-world manual-hello

# suspend/resume a CronJob
kubectl patch cronjob hello-world -p '{"spec":{"suspend":true}}'
kubectl patch cronjob hello-world -p '{"spec":{"suspend":false}}'

# delete the CronJob (Jobs it created remain unless removed)
kubectl delete cronjob hello-world
```

> Tip: use `successfulJobsHistoryLimit`, `failedJobsHistoryLimit` and `concurrencyPolicy` to control CronJob behavior.

## Summary

In this post, we reviewed core Kubernetes resources that are important for the KCNA exam, including Pod, Deployment, StatefulSet, DaemonSet, Job, and CronJob. The goal is to build a clear foundation before moving to deeper topics. In the next posts, we will continue each area with short and practical notes.
