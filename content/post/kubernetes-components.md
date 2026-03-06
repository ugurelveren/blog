---
title: "Kubernetes Components"
date: "2026-02-17"
slug: "kubernetes-components"
description: "Quick reference for Kubernetes core components: control plane and node-level components and their responsibilities."
series: "KCNA"
categories: ["technical","kubernetes"]
tags: ["kcna","kubernetes","components","control-plane","kubelet","kube-proxy"]
author: "Ugur Elveren"
toc: true
reading_time: 5
layout: "post"
---


Hello there. [In the previous article](https://blog.ugurelveren.com/post/kcna-exam-notes/) we reviewed Kubernetes and its resources and we talked about how to manage a resource. That was a basic introduction to Kubernetes. In this article we will dive deeper into Kubernetes and start discussing its architecture.
![Kubernetes components](/images/components-of-kubernetes.svg)

*Image source: [kubernetes.io](https://kubernetes.io/docs/concepts/overview/components/)*

From the image I shared above, Kubernetes has [cluster components](https://kubernetes.io/docs/concepts/overview/components/) that handle container orchestration. These are the control plane and the worker nodes. Let's focus on the control plane and the worker nodes and review how they work.

## Control Plane

The control plane is the decision making center that ensures your cluster runs as you expect and it continuously works to keep the desired state of your applications and resources.

The control plane and workloads can run on the same nodes. The control plane is not a physical node it is a collection of software components and processes that must run somewhere. When you manage your cluster on your own servers you can use dedicated control plane servers or share this functionality with worker nodes.

When you use a cluster managed by a cloud provider this changes. For example, Azure includes the control plane for some plans while AWS charges for the control plane. Most cloud providers offer around 99.95 percent uptime for the control plane and some offer different scaling tiers.

For self built clusters it is recommended to run multiple control plane nodes (3 to 5) depending on requirements to provide resilience. For small budget clusters such as development or test environments where uptime is less critical you can run control plane components on worker nodes.

### Control Plane Components

There are five control plane components that help us manage the cluster. Let us focus on each one and see how it helps.

``` ascii
Control Plane Software Stack:
├── 1. kube apiserver       (The front door)
├── 2. etcd                 (The database)
├── 3. kube scheduler       (The job assigner)
├── 4. kube controller manager (The autopilot)
└── 5. cloud controller manager (The cloud bridge)
```

#### kube-apiserver

The Kubernetes API server is the central hub for all cluster communication. It accepts requests from kubectl, controllers, the scheduler, and kubelets, then authenticates and authorizes each request to keep the cluster secure. It validates incoming requests and is the only component that reads from and writes to etcd, the cluster data store. The API server serves the Kubernetes API over HTTPS on port 6443 and runs admission webhooks to enforce policies or change requests before objects are saved.

> Kube Apiserver: The front door for all API requests

##### etcd

etcd is the cluster database. It is a distributed key value store that acts as the cluster memory. It stores cluster state such as Pods, Deployments, Services, ConfigMaps, and Secrets. Using the Raft consensus algorithm, etcd keeps data consistent across multiple replicas and provides high availability. It records a history of changes so you can view previous versions and it notifies other components when data changes. etcd also handles distributed locking when several components try to update the same data at once.

> Etcd: The database that stores everything

#### kube-scheduler

The Kubernetes scheduler decides which node a new Pod should run on. It watches for Pods without a node assignment, filters out nodes that do not meet resource needs or constraints, then scores the remaining nodes to find the best fit. After selecting the highest scoring node the scheduler binds the Pod to that node by updating the API server.

> Kube Scheduler: The matchmaker that assigns Pods to nodes

#### kube-controller-manager

The kube controller manager works as the cluster autopilot by running many controllers that watch the cluster and make fixes so the actual state matches the desired state. Each controller manages a specific resource. Important controllers include the Node Controller which monitors node health, the ReplicaSet Controller which keeps the correct number of Pod replicas, the Deployment Controller which handles updates and rollbacks, Job and CronJob controllers which run tasks to completion on schedules, the Service Controller which manages load balancer provisioning and networking, and the Endpoints Controller which connects Services to healthy Pods. These controllers run as continuous reconciliation loops and act whenever they detect drift.

> Kube Controller Manager: The autopilot that keeps things running as desired

#### cloud-controller-manager

The cloud controller manager is an optional component that connects Kubernetes to cloud provider services such as AWS, Azure, and GCP and keeps cloud specific logic out of the core system. It runs three main controllers. The Node Controller registers cloud virtual machines as Kubernetes nodes and syncs metadata such as region and instance type. The Route Controller manages cloud network routes for Pod to Pod communication across nodes. The Service Controller provisions cloud load balancers when you create a LoadBalancer Service. For example, creating a LoadBalancer Service triggers calls to the cloud API to create an external load balancer, configure it, and update the Service with the external IP. This separation keeps Kubernetes vendor neutral while automating cloud infrastructure and it is only needed for cloud deployments not for on premises clusters.

> Cloud Controller Manager: The bridge to cloud provider services

### Control Plane Architecture

``` ascii
┌─────────────────────────────────────────┐
│         kube-apiserver (Port 6443)      │ ← Central hub
│  (Only component that talks to etcd)    │
└─────────────────┬───────────────────────┘
                  │
         ┌────────┼────────┐
         ↓        ↓        ↓
    ┌──────────┐ ┌───────────┐ ┌─────────────────────┐
    │ Scheduler│ │Controllers│ │ cloud-controller-mgr│
    └──────────┘ └───────────┘ └─────────────────────┘
         ↓        ↓        ↓
    (Watch API) (Watch API) (Watch API + Cloud APIs)

    ┌──────────────────────┐
    │ etcd (Port 2379)     │ ← Database
    │ (Only API Server     │
    │  talks to etcd)      │
    └──────────────────────┘

```

##### kubectl — Quick control‑plane Checks

A few practical commands to verify and inspect control‑plane components and etcd (run node/local commands on control‑plane hosts when noted).

```bash
# verify kubectl can reach the API server and show server/client versions
kubectl version --short

# check API server readiness (returns 'ok' when healthy)
kubectl get --raw='/readyz'

# list control-plane pods (self-hosted clusters)
kubectl get pods -n kube-system -l component=kube-apiserver

# view recent apiserver logs for troubleshooting
kubectl logs -n kube-system <kube-apiserver-pod> --tail=200

# quick checks for scheduler/controller-manager/cloud-controller-manager pods
kubectl get pods -n kube-system -l component=kube-scheduler
kubectl get pods -n kube-system -l component=kube-controller-manager
kubectl get pods -n kube-system -l component=cloud-controller-manager

# check etcd members (run on a control-plane / etcd host; requires TLS certs)
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.crt --cert=/etc/etcd/etcd.crt --key=/etc/etcd/etcd.key member list
```

> Note: `etcdctl` must be executed on an etcd member with appropriate credentials; many managed clusters do not expose etcd.

## Worker Node

A worker node is simply a server or computer (physical or virtual machine) in your Kubernetes cluster where your applications actually run. Think of it like an employee in a company while the control plane acts as the manager making decisions and the worker node is the employee doing the actual work. It has resources like CPU, memory, and disk space that it uses to run your containerized applications (called Pods).

When you deploy an application to Kubernetes, the control plane decides which worker node should run it based on available resources. The worker node then pulls the container image, starts the containers, monitors them to make sure they're healthy, and reports back to the control plane about what's happening. You can have many worker nodes in a cluster (3, 10, 100, or more), and each node can run multiple applications at the same time until it runs out of resources. If a worker node fails or gets overloaded, the control plane automatically moves the applications to other healthy nodes.

### Worker Node Components

These are the core processes that must run on each worker node for Pods to function correctly. Quick verification: use `kubectl get nodes` and `kubectl describe node <node>`; on the node check `systemctl status kubelet` and the runtime (`crictl ps` or `ctr containers list`).

Every worker node runs three essential software components that make it work. The kubelet (manages containers on the node), kube-proxy (handles networking), and the container runtime (actually runs the containers like containerd or CRI-O). These three work together, kubelet receives instructions from the control plane, container runtime executes them, and kube-proxy ensures traffic flows correctly.

``` ascii
Worker Node Software Stack:
├── 1. kubelet              (The node agent / Pod manager)
├── 2. container runtime    (Runs containers: containerd / CRI-O)
├── 3. kube-proxy           (Service networking / load-balancing)
```

#### kubectl — Quick Node Checks

Handy commands to verify node health and inspect node‑level components. Run node-local commands (systemctl/journalctl/crictl) on the node itself.

```bash
# show nodes and basic readiness/roles
kubectl get nodes

# inspect node conditions, allocatable resources and recent events
kubectl describe node <node-name>

# check kubelet service on the node (run on the node)
systemctl status kubelet

# tail kubelet logs on the node for recent events
journalctl -u kubelet -n 200 --no-pager

# list containers via CRI (requires crictl installed on the node)
crictl ps -a

# check kube-proxy DaemonSet and its pods
kubectl get daemonset kube-proxy -n kube-system
kubectl get pods -n kube-system -l k8s-app=kube-proxy -o wide

# containerd example (run on the node)
ctr -n k8s.io containers list  # or use 'nerdctl ps' / 'docker ps' depending on runtime
```

> Tip: `kubectl describe node` often reveals kubelet/eviction/probe issues; use `journalctl` or `crictl` on the node for deeper inspection.

#### Kubelet

The Kubelet is the primary agent that runs on every worker node and it acts as the node manager and Pod manager. It watches for Pods assigned to its node by the scheduler and manages their entire lifecycle like starting, stopping, and restarting containers as needed. The kubelet pulls container images from registries, mounts storage volumes, and sets up networking with the help of CNI plugins. It continuously monitors Pod health by running liveness and readiness probes, collects resource usage metrics like CPU and memory, and regularly reports the status of both the node and its Pods back to the control plane through the API server.

> Kubelet: The node agent that runs and manages Pods and reports node and Pod status to the control plane.

#### Kube Proxy

The Kube Proxy is a network proxy that runs on every worker node and makes Kubernetes Services work. It maintains network rules (using iptables, ipvs, or nftables) that enable communication between Services and Pods. When traffic is sent to a Service, kube-proxy intercepts it and load balances the requests across the healthy Pod endpoints. This allows Services to act as stable access points while kube-proxy handles routing the actual traffic to the correct Pods, enabling seamless Service discovery and communication within the cluster.

> Kube Proxy: The node network proxy that implements Service routing and load balancing.

#### Container Runtime

The Container Runtime is the low level software that actually runs containers on each node. It handles the fundamental tasks of pulling container images from registries, unpacking them, and creating isolated container processes using Linux namespaces and cgroups. The runtime manages the complete container lifecycle—starting, stopping, and deleting containers—while also handling networking and storage. Kubernetes communicates with container runtimes through the Container Runtime Interface (CRI), a standardized API that allows you to use different runtimes like containerd or CRI-O interchangeably. This design keeps Kubernetes runtime-agnostic, making it easy to swap runtimes and allowing both Kubernetes and container runtimes to evolve independently.

> Container Runtime: The software that pulls images and runs containers on the node.

##### Container Runtime Interface (CRI)

Container Runtime Interface (CRI) is the standardized API that Kubernetes uses to communicate with any container runtime. The flow works like this: kubelet talks to the CRI API, which then communicates with the actual container runtime (like containerd or CRI-O), which finally interacts with the Linux kernel to run containers. This standardization offers three key benefits: Kubernetes remains runtime-agnostic and doesn't depend on a specific runtime, you can easily swap container runtimes without changing Kubernetes itself, and both Kubernetes and container runtimes can innovate and improve independently.

- **containerd** is the industry-standard container runtime that was originally extracted from Docker and is now maintained by the CNCF. It serves as the default runtime for most Kubernetes distributions including EKS, AKS, GKE, and Docker Desktop. containerd is lightweight and efficient, with native CRI support that allows direct integration with kubelet without needing additional adapters. You can interact with it using various CLI tools like ctr, crictl, or nerdctl, and it communicates through its socket at /run/containerd/containerd.sock. Its widespread adoption and streamlined design make it the go-to choice for modern Kubernetes clusters.

- **CRI-O** is a lightweight container runtime built specifically for Kubernetes, originally created by Red Hat. It's designed to be minimal and focused, providing only what Kubernetes needs without any extra features, which keeps its footprint small and efficient. CRI-O is OCI (Open Container Initiative) compliant and is particularly popular in Red Hat OpenShift and some on-premises clusters. It communicates through its socket at /var/run/crio/crio.sock and serves as a streamlined alternative for users who want a runtime purpose-built for Kubernetes without additional overhead.

- **Docker**  was the original container runtime for Kubernetes, but native support was removed in Kubernetes 1.24. While you can still use Docker through a workaround called the cri-dockerd shim, it's not recommended because it adds extra layers (kubelet → cri-dockerd → dockerd → containerd), creating more overhead and complexity. This path is now deprecated, so it's better to use containerd or CRI-O directly. However, it's important to note that Docker images themselves still work perfectly with all container runtimes—only Docker as a runtime has been phased out.

### Worker Node Architecture

``` ascii
┌─────────────────────────────────────────────────────────────────┐
│                        WORKER NODE                              │
│                     (Physical/Virtual Machine)                  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                      kubelet                             │   │
│  │             (Node Agent / Pod Manager)                   │   │
│  │  • Watches API Server for Pod assignments                │   │
│  │  • Manages Pod lifecycle                                 │   │
│  │  • Reports node/Pod status                               │   │
│  │  • Runs health checks                                    │   │
│  └────────┬─────────────────────────────────┬───────────────┘   │
│           │                                 │                   │
│           │ talks to                        │ talks to          │
│           ↓                                 ↓                   │
│  ┌─────────────────────┐         ┌──────────────────────────┐   │
│  │  Container Runtime  │         │      kube-proxy          │   │
│  │   (containerd/      │         │   (Network Manager)      │   │
│  │     CRI-O)          │         │                          │   │
│  │                     │         │  • Manages iptables/     │   │
│  │  • Pulls images     │         │    ipvs rules            │   │
│  │  • Runs containers  │         │  • Routes Service        │   │
│  │  • Manages lifecycle│         │    traffic to Pods       │   │
│  └──────────┬──────────┘         │  • Load balances         │   │
│             │                    └──────────┬───────────────┘   │
│             │                               │                   │
│             ↓                               ↓                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                    RUNNING PODS                         │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐               │    │
│  │  │  Pod 1   │  │  Pod 2   │  │  Pod 3   │               │    │
│  │  │ [nginx]  │  │ [redis]  │  │  [app]   │    ...        │    │
│  │  └──────────┘  └──────────┘  └──────────┘               │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
         ↑                                            ↑
         │                                            │
         │ reports status                             │ network traffic
         │ watches for Pods                           │ (Services)
         │                                            │
         ↓                                            ↓
┌────────────────────┐                    ┌──────────────────────┐
│   Control Plane    │                    │   Other Nodes/       │
│   (API Server)     │                    │   External Clients   │
└────────────────────┘                    └──────────────────────┘

```

## Summary

This article explained the two main parts of a Kubernetes cluster and what each part does. The control plane makes decisions and stores state in etcd while components such as the kube apiserver, the scheduler, and the controller manager keep the cluster consistent. Worker nodes run your applications and rely on kubelet, a container runtime, and kube proxy together with networking plugins and node level addons. Together these components schedule workloads, keep services reachable, and maintain the desired state of your applications.
