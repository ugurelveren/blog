---
title: "Understanding Containers & Their Lifecycle in Kubernetes"
date: "2026-03-05"
series: "KCNA"
slug: "containers-lifecycle-kubernetes"
description: "Deep dive into containers, environment configuration, and lifecycle within Kubernetes."
categories: ["technical","kubernetes"]
tags: ["kubernetes","containers","lifecycle","environment"]
author: "Ugur Elveren"
toc: true
reading_time: 7
layout: "post"
---

As I've noted in earlier posts, containers predate Kubernetes. Docker brought them into the mainstream by making image build and runtime management almost trivial. For a development team the first obvious win was reproducibility – build an image once and run it on a developer laptop, a CI runner, or a production node without changing a line of code. The “works on my machine” problem simply went away. But once you start running dozens or hundreds of containers, the question becomes: how do you schedule them, monitor them, network them and recover from failures? That is the problem Kubernetes solves.

![Containers on Unsplash](/images/containers.jpg)


In this article I want to dissect containers from an engineer's perspective. We'll look at the primitive building blocks, how configuration is injected, the states a container traverses inside a Pod, and finally the runtime that actually executes the process. Wherever possible I'll include concrete commands or snippets I've used in real clusters.

## Fundamentals of a Container

Under the hood a container is just a process with extra isolation: **namespaces** (pid, net, mnt, ipc, uts, user) and **cgroups** enforce boundaries while the host kernel does the heavy lifting. For a deeper look at namespaces see this primer: https://thenewstack.io/what-are-linux-namespaces-and-how-are-they-used/.

Because containers re-use the host kernel they are very light and start in milliseconds, letting you pack dozens or hundreds onto a single node. Their filesystem is built from an immutable, layered image pulled from a registry; when the runtime instantiates the image you get the running container instance.

### Containers vs. Virtual Machines

A virtual machine includes a full guest OS with its own kernel and device drivers. A container reuses the host kernel and only isolates user space. That's why VMs are measured in gigabytes and take minutes to boot, while containers are megabytes with sub‑second startup.

For day‑to‑day operations the practical advice is: use VMs when you need full kernel feature sets or strict security boundaries; use containers when you care about density and portability.

## Configuration and Environment

Hardcoding environment‑specific values in images breaks the “build once” strategy. The container image should be the same across dev, staging, and prod; what changes is the configuration.

Kubernetes exposes several mechanisms to wire configuration into a container:

* `env` variables in Pod specs
* `envFrom` with `ConfigMap` or `Secret`
* mounting `ConfigMap`/`Secret` as a volume
* command‑line arguments

Example Pod snippet:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp
spec:
  containers:
  - name: app
    image: myrepo/web:1.0
    env:
    - name: DATABASE_URL
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: url
    - name: LOG_LEVEL
      value: "info"
```

Kubernetes injects these values at container start by generating an environment block or by creating files under `/var/run/secrets/...` and binding them inside the container. I usually favoured `env` for simple key‑value pairs and volume mounts when the application expects a config file.

**ConfigMaps** are for non‑sensitive data and support later updates (the kubelet will reload the volume periodically). **Secrets** are base64‑encoded; they are not encrypted unless you enable the `EncryptionConfiguration`. In production I usually integrate with HashiCorp Vault or AWS KMS for proper secrets management.

## Lifecycle of a Container in Kubernetes

A container’s state is reflected in the Pod status:

* `Waiting` – not yet started, often pulling an image or waiting for an init container.
* `Running` – main process has started.
* `Terminated` – process has exited (either successfully or with an error).

You can observe these with `kubectl describe pod` or:

```sh
kubectl get pod webapp -o jsonpath='{.status.containerStatuses[0].state}'
```

Containers restart according to the Pod’s `restartPolicy`:

* `Always` (default) – restart on any exit.
* `OnFailure` – restart only if exit code ≠ 0.
* `Never` – don’t restart.

I typically set `OnFailure` for batch jobs and `Always` for services.

### Hooks and init containers

You can hook into the lifecycle with `postStart` and `preStop` actions. I use them to trigger cache priming or to send shutdown notifications:

```yaml
lifecycle:
  postStart:
    exec:
      command: ["/bin/sh","-c","/usr/local/bin/prime-cache"]
  preStop:
    exec:
      command: ["/bin/sh","-c","sleep 5"]
```

Init containers are useful for one‑off initialization tasks. They run sequentially and must succeed before the main containers start:

```yaml
initContainers:
- name: migrate
  image: myrepo/migrator:1.0
  command: ["/bin/sh","-c","./migrate.sh && exit 0"]
```

If any init container fails the Pod is restarted until the sequence completes successfully.

### Probes

Health probes ensure the kubelet can make intelligent decisions:

```yaml
livenessProbe:
  httpGet: {path: "/health", port: 8080}
  initialDelaySeconds: 15
readinessProbe:
  httpGet: {path: "/ready", port: 8080}
  periodSeconds: 5
```

A failed readiness probe removes the Pod from Services; a failed liveness probe causes a restart.

## Container Runtime

The container runtime is the component on each node that actually creates and runs container processes. Kubernetes talks to it via the Container Runtime Interface (CRI).

Popular runtimes:

* **containerd** – default in most distributions; lightweight and focuses solely on running containers.
* **CRI‑O** – another minimal runtime, particularly common in Red Hat/OpenShift environments.
* **Docker** – deprecated as a CRI endpoint; Kubernetes used to launch containers through the Docker Engine, which itself used containerd.

The kubelet uses the CRI gRPC API; you can inspect or debug the runtime directly with `crictl`:

```sh
crictl ps
crictl pull nginx:latest
crictl inspect $(crictl ps -q | head -1)
```

Behind the scenes the kubelet translates Pod specs into `CreateContainer` and `StartContainer` gRPC calls. When a probe fails or a Pod is deleted it sends the corresponding `StopContainer`/`RemoveContainer` calls.

## Practical Example
Putting many of the concepts together, here's a pod spec I use in production for a cache‑priming service:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: cache-warm
spec:
  restartPolicy: OnFailure
  initContainers:
  - name: init-db
    image: busybox
    command: ["sh","-c","until nc -z db 5432; do sleep 1; done"]
  containers:
  - name: app
    image: myrepo/cache-warm:2.3
    env:
    - name: TARGET
      value: "https://api.example.com"
    lifecycle:
      postStart:
        exec:
          command: ["sh","-c","/usr/local/bin/warm --target=$TARGET &"]
      preStop:
        exec:
          command: ["sh","-c","killall warm; sleep 2"]
    livenessProbe:
      httpGet: {path: "/health", port: 8080}
      initialDelaySeconds: 10
    readinessProbe:
      httpGet: {path: "/ready", port: 8080}
      periodSeconds: 5
```

This article has focused on concrete, operational details rather than analogies. The goal is to give you a mental model you can apply when you debug pods or design new images.

In this example, the postStart hook logs when the container starts and simulates a warmup period. The preStop hook logs the shutdown time, sends a graceful shutdown signal to nginx, and waits 10 seconds to finish processing requests. The probes ensure the container is healthy and ready to receive traffic.

### Environment variable configuration

Here are different ways to configure environment variables in your containers, from simple to more advanced.

**Option 1: Direct environment variables**

``` yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-env
spec:
  containers:
  - name: myapp
    image: myapp:latest
    env:
    - name: DATABASE_HOST
      value: "postgres.default.svc.cluster.local"
    - name: DATABASE_PORT
      value: "5432"
    - name: APP_ENV
      value: "production"
    - name: LOG_LEVEL
      value: "info"
```

**Option 2: Using ConfigMap**

``` yaml
# First create a ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database.host: "postgres.default.svc.cluster.local"
  database.port: "5432"
  app.environment: "production"
---
# Then reference it in your Pod
apiVersion: v1
kind: Pod
metadata:
  name: app-with-configmap
spec:
  containers:
  - name: myapp
    image: myapp:latest
    env:
    - name: DATABASE_HOST
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database.host
    - name: DATABASE_PORT
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database.port
    # Or load all keys from ConfigMap as environment variables
    envFrom:
    - configMapRef:
        name: app-config
```

**Option 3: Using Secrets**
``` yaml
# First create a Secret
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
data:
  # Values must be base64 encoded
  db-password: cGFzc3dvcmQxMjM=  # "password123"
  api-key: bXlzZWNyZXRrZXk=      # "mysecretkey"
---
# Then reference it in your Pod
apiVersion: v1
kind: Pod
metadata:
  name: app-with-secrets
spec:
  containers:
  - name: myapp
    image: myapp:latest
    env:
    - name: DATABASE_PASSWORD
      valueFrom:
        secretKeyRef:
          name: app-secrets
          key: db-password
    - name: API_KEY
      valueFrom:
        secretKeyRef:
          name: app-secrets
          key: api-key
```

**Mixing all approaches:**

``` yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-complete-config
spec:
  containers:
  - name: myapp
    image: myapp:latest
    env:
    # Direct value
    - name: APP_NAME
      value: "my-application"
    # From ConfigMap
    - name: DATABASE_HOST
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database.host
    # From Secret
    - name: DATABASE_PASSWORD
      valueFrom:
        secretKeyRef:
          name: app-secrets
          key: db-password
    # Load all ConfigMap keys
    envFrom:
    - configMapRef:
        name: app-config
```

### Basic runtime commands (crictl, ctr)
Once your containers are running, you'll need tools to inspect and debug them. Here are the most useful runtime commands:

**crictl (CRI tool - works with containerd and CRI-O)**

```bash
# List all running containers
crictl ps

# List all containers including stopped ones
crictl ps -a

# List all images on the node
crictl images

# Pull an image
crictl pull nginx:latest

# Get detailed information about a container
crictl inspect <container-id>

# View container logs
crictl logs <container-id>

# View the last 50 lines of logs
crictl logs --tail=50 <container-id>

# Follow logs in real-time
crictl logs -f <container-id>

# Execute a command inside a running container
crictl exec -it <container-id> /bin/sh

# List all pods
crictl pods

# Get pod details
crictl inspectp <pod-id>

# Check runtime version and info
crictl version
crictl info

# Remove stopped containers
crictl rm <container-id>

# Remove an image
crictl rmi <image-id>
```
**ctr (containerd CLI - lower level)**

``` bash
# List running containers in the k8s.io namespace
ctr -n k8s.io containers list

# List images
ctr -n k8s.io images list

# Pull an image
ctr -n k8s.io images pull docker.io/library/nginx:latest

# Check containerd version
ctr version

# View container tasks (running processes)
ctr -n k8s.io tasks list

# Export an image to a tar file
ctr -n k8s.io images export nginx.tar docker.io/library/nginx:latest

# Import an image from a tar file
ctr -n k8s.io images import nginx.tar
```

**Important notes:**
- crictl is the recommended tool for Kubernetes debugging because it understands CRI and works with any CRI-compliant runtime
- Most containerd operations in Kubernetes use the k8s.io namespace, so always include -n k8s.io with ctr commands
- These tools are for debugging and inspection - don't use them to manually create containers. Let Kubernetes manage the lifecycle!
- You need to run these commands on the actual Kubernetes node where containers are running, usually with sudo or root access


**Quick debugging workflow:**
```bash
# Find your pod
crictl pods | grep my-app

# Find containers in that pod
crictl ps | grep my-app

# Check container logs
crictl logs <container-id>

# Get detailed container info
crictl inspect <container-id>

# Execute commands inside the container
crictl exec -it <container-id> /bin/sh
```

## Conclusion

Containers are the heart of Kubernetes, and understanding how they work makes everything else easier. We covered a lot in this article - from what containers are and how they differ from VMs, to how they get their configuration, go through their lifecycle, and actually run on your nodes. Each piece plays an important role in making your applications reliable and scalable.

The key takeaways: containers are lightweight and portable, they use environments to stay flexible, they go through predictable states that you can control with hooks and probes, and they rely on container runtimes to do the actual work. Kubernetes orchestrates all of this beautifully, handling the complexity so you can focus on building great applications.

Now that you understand containers deeply, you're ready to work more effectively with Kubernetes. You'll troubleshoot problems faster, write better Pod specifications, and make smarter decisions about how to run your applications. Keep experimenting with the practical examples, and you'll master containers in no time! 
