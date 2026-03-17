---
title: "Kubernetes Scheduler"
date: "2026-03-11"
series: "KCNA"
slug: "kubernetes-scheduler"
description: "Overview of the Kubernetes scheduler: how it selects nodes and scheduling strategies."
categories: ["technical","kubernetes"]
tags: ["kubernetes","scheduler","scheduling"]
author: "Ugur Elveren"
toc: true
reading_time: 6
layout: "post"
draft: true
---

Hey, since we have been going deep on Kubernetes, this article starts a discussion about what the scheduler is and more. First, let’s discuss what the Kubernetes scheduler is.

The Kubernetes scheduler is the key control plane component that watches for newly created Pods that have no node assigned and selects the best node for them to run. From this description, we can understand that it sits at the intersection of optimal resource utilization, performance, and high availability of applications.

## kube-scheduler

`kube-scheduler` is the default control plane component in Kubernetes that assigns Pods to nodes. The scheduler determines which node is available, ranks each valid node, and binds Pods to the most suitable nodes. There are some alternatives to `kube-scheduler` for different cases. For example, Volcano is specialized for batch/AI workloads and YuniKorn, developed by Apache, offers multi-tenancy capacity for big data workloads. However, in this article we are not going to dive deeply into alternatives for `kube-scheduler`.

### Node selection in kube-scheduler

`kube-scheduler` selects nodes with a two‑phase process. The first phase is filtering and the second step is scoring. The filtering step finds feasible nodes for the Pod. The filter checks nodes and returns nodes which have enough resources to assign the Pod to that specific node.

The second step is scoring. The scheduler ranks the remaining nodes to choose the most suitable placement. The scheduler assigns a score to each node. Finally, after scoring, `kube-scheduler` chooses the node with the highest score. If there is a tie for the highest score, `kube-scheduler` randomly selects one of the top-scoring nodes for assignment.

### What makes a node feasible

During the filtering phase, the Kubernetes scheduler checks which nodes can run a Pod. It uses different checks (called filter plugins) to test each node. Common checks include:

- [PodFitResources](https://github.com/kubernetes/kubernetes/tree/master/pkg/scheduler/framework/plugins/noderesources) – does the node have enough CPU and memory?
- Does it have the right labels?
- Can the Pod tolerate the node's taints?
- Does it meet pod affinity rules?

The scheduler also checks node health, storage access, and available ports. A node must pass **all** checks to be considered feasible. If it fails even one check, that node is removed from the list. If no nodes pass all checks, the Pod stays in `Pending` state until something changes.

## nodeSelector – Simple Node Selection

The `nodeSelector` is a simple key‑value pair in a Pod specification which allows the scheduler to run Pods only on nodes that have all specified labels. This is a basic filter, ensuring that workloads run on nodes with particular labels.

This is the most straightforward method for node selection and is better for small clusters or simple requirements. It runs exact matches only. As you might imagine, it is case sensitive; the recommendation is to use lowercase for all node labels to avoid scheduling issues.

There are some good use cases, such as environment segregation. For example, if you run dev and test workloads together, this can help separate different environments. Also, with this approach we can utilize specialized hardware like SSD storage or GPUs for some nodes. Basically, this helps us isolate nodes based on our rules.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: example-pod
spec:
  containers:
  - name: nginx
    image: nginx
  nodeSelector:
    disktype: ssd
```

## Node Affinity – Advanced Node Selection

Node affinity is an advanced Kubernetes scheduling feature that constrains which nodes a Pod is scheduled on based on node labels, acting as a more flexible, expressive alternative to `nodeSelector`. It supports logical operators (`In`, `NotIn`, `Exists`) for complex rules and offers both hard and soft rules.

Node affinity is preferred over `nodeSelector` because it provides more expressive rules, supports both hard and soft constraints, and offers more advanced logic using operators beyond simple matching. Basically, if we need complicated matching we can consider node affinity instead of `nodeSelector`.

### Hard rules (`requiredDuringSchedulingIgnoredDuringExecution`)

The scheduler must satisfy this rule to place the Pod; if the requirements are not met, Pods will remain in the Pending state.

### Soft rules (`preferredDuringSchedulingIgnoredDuringExecution`)

The scheduler tries to satisfy this rule but will not fail to schedule the Pod if no nodes match. Nodes that match the preference are scored higher; however, if there are no matching nodes, the Pod will be scheduled on other available nodes.

### Weight‑based scoring

In Kubernetes, weight‑based scoring is used to define preferences within soft affinity rules. This mechanism influences the scheduler’s ranking of the suitable nodes without enforcing a hard constraint.

### Supported operators

In Kubernetes, advanced node selection using operators is implemented through node affinity `matchExpressions` rather than the basic `nodeSelector` field. The supported operators are `In`, `NotIn`, `Exists`, `DoesNotExist`, `Gt` (Greater Than), and `Lt` (Less Than).

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: affinity-example
spec:
  affinity:
    nodeAffinity:
      # REQUIRED: Pod will not run if no SSD nodes exist
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
      # PREFERRED: Scheduler prefers this zone, but will use others
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 80
        preference:
          matchExpressions:
          - key: zone
            operator: In
            values:
            - us-east-1
      - weight: 20 # Lower weight indicates weaker preference
        preference:
          matchExpressions:
          - key: "zone"
            operator: In
            values:
            - "us-west-2a"
  containers:
  - name: nginx
    image: nginx
```

## Pod Affinity and Anti-Affinity

Pod affinity and anti-affinity are Kubernetes scheduling rules that control where Pods are placed based on the labels of other Pods already running in the cluster. These mechanisms optimize network performance, ensure fault tolerance, and balance workload distribution across your cluster.

### Scheduling based on other Pods

Instead of asking "which node should I run on?", these rules ask "which other Pods should I run near (affinity) or away from (anti-affinity)?" The scheduler evaluates the labels of Pods in a given topology to determine if a new Pod can land there.

### Understanding `topologyKey`

The `topologyKey` defines the domain or boundary for the rule. It must be a label key that exists on your nodes.

- `kubernetes.io/hostname:` Rules apply to the individual node (e.g., "Don't put two of these on the same node").
- `topology.kubernetes.io/zone:` Rules apply across Availability Zones (e.g., "Keep these pods in the same zone").
- `topology.kubernetes.io/region:` Rules apply across entire geographical regions.

### Pod Affinity Use Cases

It is like co-locating related services — for example, placing a frontend and backend in the same zone to reduce network latency. Or data locality: scheduling an application Pod on the same node as its dedicated cache or data processor.

### Anti-Affinity Use Cases

High availability is one of the top reasons. Spreading replicas of a critical service across different nodes or zones ensures a single failure doesn’t take down the entire service.

Also, resource isolation is another good example: preventing "noisy neighbors" by ensuring two resource-intensive Pods don't share the same node.

### Performance

One of the biggest mistakes is rule complexity. Using required anti-affinity on a high number of replicas might lead to unscheduled Pods if you run out of distinct nodes or zones. Also, on large clusters with hundreds or thousands of nodes, evaluating affinity rules for every Pod is computationally expensive and can significantly slow down the scheduler.
A node should be considered feasible when it supports all hard constraints such as CPU, RAM, and GPU. As we mentioned, there are some alternatives to `kube-scheduler`; these constraints can be plenty.

First, it should support resource requests and limits. Requests specify the bare minimum resources, and limits define the maximum resources a Pod can consume.

## Taints and Tolerations

Kubernetes taints and tolerations work together to ensure pods are not scheduled on inappropriate nodes. Taints are applied to nodes to repel pods, while tolerations are applied to pods to allow them to schedule on tainted nodes. Key effects include NoSchedule (prevents new pods), PreferNoSchedule (avoids if possible), and NoExecute (evicts existing pods)

### Repelling Pods from specific nodes

To repel pods from a specific node in Kubernetes, you should use taints. Taints are applied to nodes and work in conjunction with tolerations, which are applied to pods, to control scheduling.

The process involves two main steps: applying a taint to the node you want to repel pods from, and ensuring the specific pods that are allowed to run on that node have a matching toleration.

### Common use cases

Taints and tolerations are primarily used for dedicated node allocation, ensuring specialized hardware like GPUs or expensive Spot Instances are reserved for specific workloads. By tainting these nodes, you prevent general-purpose pods from consuming their resources, allowing only pods with matching tolerations to utilize the specialized infrastructure.

They are also essential for node health and maintenance, where Kubernetes automatically taints nodes experiencing issues like not-ready or unreachable. This triggers the eviction of existing pods to healthier nodes and prevents new pods from scheduling on failing hardware until the issue is resolved or maintenance is complete.

### Example configuration

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-worker
spec:
  containers:
  - name: cuda-container
    image: nvidia/cuda:11.0-base
  # The toleration must match the taint applied to the node
  tolerations:
  - key: "hardware"
    operator: "Equal"
    value: "gpu"
    effect: "NoSchedule"

```

## nodeName - Direct Node Assigment

## nodeName - Direct Node Assigment

nodeName is the most direct form of node assignment in Kubernetes. It completely bypasses the scheduler and forces a pod onto a specific node by its hostname.
When we use direct binding, the pod is sent directly to the kubelet on the target node.
It ignores constraints because it bypasses the scheduler, the pod ignores taints and other scheduling restrictions. It will attempt to run on the node even if the node is "unschedulable." This method has the highest priority and overrides all other placement rules.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: direct-assignment-example
spec:
  # The exact name of the target node
  nodeName: worker-01 
  containers:
  - name: nginx
    image: nginx:1.25
```

## Pod Topology Spread Constraints

Pod Topology Spread Constraints provide a declarative way to control how pods are distributed across failure domains—such as regions, zones, and nodes—to maximize high availability and resource efficiency. Unlike pod anti-affinity, which is a binary "yes/no" for co-location, spread constraints allow for a more nuanced "skew" between domains.

a. Spreading Pods across failure domains
b. Topology domains (regions, zones, nodes)
c. Pod topology labels
d. Using Downward API to access topology information
e. Example YAML configuration

1. Pod Scheduling Readiness (schedulingGates)
a. The problem: unnecessary scheduler churn
b. What are scheduling gates?
c. How to use schedulingGates
i. Creating Pods with gates
ii. Checking gate status
iii. Removing gates to trigger scheduling
d. Observability with metrics
e. Mutable Pod Scheduling Directives
i. Rules for modifying scheduling while gated
ii. Tightening constraints only

1.  Scheduling Profiles and Customization
a. Multiple scheduler profiles
b. Plugin stages (QueueSort, Filter, Score, Bind)
c. Per-profile node affinity configuration
d. Custom scheduling policies
e. DaemonSet considerations
1.  Best Practices
a. Choosing the right scheduling method
i. nodeSelector vs node affinity
ii. When to use pod affinity/anti-affinity
iii. When to avoid nodeName
b. Performance considerations
i. Pod affinity in large clusters (>hundreds of nodes)
c. Security considerations
i. NodeRestriction admission plugin
ii. Label key prefixes for security
d. Node label best practices
1.  Common Use Cases and Patterns
a. High availability deployments
b. Latency-sensitive workload co-location
c. Multi-tenant scheduling isolation
d. Resource optimization
e. Preventing scheduling until resources are ready
1.  Quick Reference
a. Comparison table of all scheduling methods
b. Operator reference guide
c. Common kubectl commands
1.  Conclusion
a. Summary of scheduling methods
b. Choosing the right approach for your workload
c. Additional resources