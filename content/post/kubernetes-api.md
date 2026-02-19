---
title: "Kubernetes API"
date: "2026-02-19"
series: "KCNA"
slug: "kubernetes-api"
description: "Quick reference for the Kubernetes API: resources, groups, verbs, and how to interact programmatically."
summary: "Notes and examples for using the Kubernetes REST API and client libraries."
categories: ["technical","kubernetes"]
tags: ["kubernetes","api","apiserver","client-go","kubectl"]
author: "Ugur Elveren"
toc: true
reading_time: 6
layout: "post"
---

The Kubernetes API is the central hub that powers everything in a Kubernetes cluster (see the official docs: [Kubernetes API concepts](https://kubernetes.io/docs/concepts/overview/kubernetes-api/)). It is a collection of HTTP endpoints that allow users, applications, and internal components to communicate with the cluster and manage its resources. Every interaction you have with Kubernetes, whether you realize it or not, goes through this API. It acts as the gateway between you and the cluster, processing requests and translating them into actions that create, modify, or delete resources. Without the API, there would be no way to tell Kubernetes what you want it to do or to check the current state of your applications.

When you run a kubectl command to deploy an application or check the status of your pods, you are making an API call behind the scenes. The kubectl tool is essentially a client that formats your commands into HTTP requests and sends them to the API server. Similarly, when you apply a YAML configuration file, kubectl reads that file and makes the appropriate API calls to create or update resources. Even the internal components of Kubernetes, like the scheduler and controller manager, use the same API to watch for changes and perform their tasks. This unified approach makes the Kubernetes API the absolute foundation of everything that happens in your cluster, ensuring that all components speak the same language and work together seamlessly.

## What is the API server

The API server is the central component of the Kubernetes control plane and serves as the brain of your entire cluster. It runs as a process called kube-apiserver and is the only component that directly communicates with etcd, the database where all cluster data is stored. When you think about the control plane, the API server is the most critical piece because without it, nothing else in Kubernetes can function.

The API server acts as the gateway to your cluster, meaning that every component and user must go through it to interact with Kubernetes. It processes all the requests, enforces security policies, validates the data you send, and ensures that the desired state you declare is recorded properly. This centralized design ensures consistency and security across your entire cluster, making the API server the single source of truth for everything happening in Kubernetes.

Every interaction in Kubernetes flows through the API server. When you use kubectl to deploy an application, your commands are sent to the API server. When the kubelet on a worker node needs to report the status of pods or pull new instructions, it talks to the API server. Controllers in the control plane continuously watch the API server for changes and take action to maintain the desired state of your resources. Even the scheduler communicates exclusively through the API server to assign pods to nodes.

``` ascii

                          CONTROL PLANE
         ┌────────────────────────────────────────────────┐
         │                                                │
         │         ┌──────────────────────┐               │
         │         │                      │               │
         │         │    API Server        │◄──────────────┼──────── External Users
         │         │  (kube-apiserver)    │               │         (kubectl, dashboards)
         │         │                      │               │
         │         └──────┬───────────────┘               │
         │                │                               │
         │                │ Read/Write                    │
         │                │                               │
         │         ┌──────▼───────────────┐               │
         │         │                      │               │
         │         │        etcd          │               │
         │         │  (Cluster Database)  │               │
         │         │                      │               │
         │         └──────────────────────┘               │
         │                ▲                               │
         │                │                               │
         │    ┌───────────┼───────────┬─────────┐         │
         │    │           │           │         │         │
         │    │           │           │         │         │
         │ ┌──▼────┐  ┌──▼────┐  ┌───▼──┐  ┌───▼───┐      │
         │ │Sched  │  │Control│  │Cloud │  │Controller│   │
         │ │uler   │  │Manager│  │Control│ │Manager│      │
         │ └───────┘  └───────┘  └──────┘  └───────┘      │
         │                                                │
         └────────────────────────────────────────────────┘
                                ▲
                                │
                                │ Watch/Update
                                │
         ┌──────────────────────┴───────────────────────┐
         │                                              │
         │              WORKER NODES                    │
         │                                              │
         │  ┌──────────────┐        ┌──────────────┐    │
         │  │   Node 1     │        │   Node 2     │    │
         │  │              │        │              │    │
         │  │  ┌────────┐  │        │  ┌────────┐  │    │
         │  │  │kubelet │──┼────────┼──│kubelet │  │    │
         │  │  └────────┘  │        │  └────────┘  │    │
         │  │              │        │              │    │
         │  │  ┌────────┐  │        │  ┌────────┐  │    │
         │  │  │ Pods   │  │        │  │ Pods   │  │    │
         │  │  └────────┘  │        │  └────────┘  │    │
         │  └──────────────┘        └──────────────┘    │
         │                                              │
         └──────────────────────────────────────────────┘
```

### How the API is Organized

The Kubernetes API is organized into groups to keep related resources together and make it easier to manage. There are two main types of API groups: the core group and named groups. The core group, also called the legacy group, contains fundamental resources like Pods, Services, ConfigMaps, and Namespaces. These resources are so essential to Kubernetes that they don't need a group name in their API path, so you'll see them referenced simply as /api/v1. Named groups, on the other hand, have explicit names like apps, batch, networking.k8s.io, and storage.k8s.io. These groups contain more specialized resources and are accessed through paths like /apis/apps/v1 or /apis/batch/v1. This organization allows Kubernetes to add new features and resource types without cluttering the core API or breaking existing functionality.

Each API group has different versions that indicate the maturity and stability of the resources within that group. Kubernetes uses three version levels: alpha, beta, and stable. Alpha versions like v1alpha1 are experimental features that may change or be removed without notice. Beta versions like v1beta1 are more tested and stable but might still have minor changes. Stable versions are marked with v1, v2, or similar labels and are fully supported and safe to use in production.

Resources are the actual objects you can create and manage through the API. Each resource belongs to an API group and has a specific version. For example, when you create a Deployment, you're using the apps API group, version v1, and the deployments resource. The full API path looks like apps/v1/deployments. This structure tells Kubernetes exactly which resource type you're working with and which version of that resource's definition to use.

## How Requests Flow

When you run kubectl apply to create or update a resource in your Kubernetes cluster, your request goes through a series of carefully designed steps to ensure security and consistency. First, the API server receives your request and starts the authentication process to figure out who you are by checking credentials like certificates or tokens. Once authenticated, the request moves to the authorization phase where Kubernetes determines what you're allowed to do using policies like Role-Based Access Control (RBAC). If you lack the necessary permissions, the request is denied immediately. After passing authorization, your request enters the admission control phase where a series of admission controllers examine whether the request is valid, inject default values, enforce quotas, or modify your request according to cluster policies.

Once your request passes all admission controllers, the API server validates the resource definition against its schema to ensure all required fields are present and correctly formatted. If validation succeeds, the API server writes the resource's desired state to etcd, the distributed key-value store that serves as Kubernetes' database. After the data is safely stored in etcd, the API server sends a response back to your kubectl client confirming that the resource was created or updated. At this point, controllers watching the API server notice the new or changed resource and begin working to make the actual state of your cluster match the desired state you just declared.

Note: the processing order is => Admission → VALIDATE → etcd → RESPONSE (diagram shows the logical flow).

``` ascii
kubectl apply          ┌──────────────┐      ┌──────────────┐      ┌──────────────┐
                  ───► │ 1. AUTH      │ ───► │ 2. AUTHZ     │ ───► │ 3. ADMISSION │
                       │ Who are you? │      │ What can     │      │ Is this      │
                       │              │      │ you do?      │      │ valid?       │
                       └──────────────┘      └──────────────┘      └──────┬───────┘
                                                                          │
                       ┌──────────────┐      ┌──────────────┐             ▼
                       │ 6. RESPONSE  │ ◄─── │ 5. ETCD      │ ◄─── ┌──────────────┐
                       │ Success!     │      │ Store state  │      │ 4. VALIDATE  │
                       │              │      │              │      │ Schema check │
                       └──────┬───────┘      └──────────────┘      └──────────────┘
                              │
                              ▼
                    Controllers reconcile
```

## Ways to Interact with the API

The most common way to interact with the Kubernetes API is through kubectl, the official command line tool. kubectl abstracts away the complexity of making HTTP requests and provides user-friendly commands for managing your cluster resources. When you run a command like kubectl get pods, kubectl translates that into an API request, sends it to the API server, and formats the response nicely for you to read.

For more direct control or automation scenarios, you can use curl or any HTTP client to make raw API calls to the Kubernetes API server. This approach requires you to handle authentication yourself by passing a bearer token in the request headers. You also need to know the exact API endpoint paths and request formats, which makes it useful for testing and debugging.

For building applications that need to interact with Kubernetes programmatically, client libraries are the best choice. Kubernetes provides official client libraries for multiple programming languages including Python, Go, Java, JavaScript, and .NET. These libraries handle authentication, request formatting, and response parsing automatically, making it much easier to write code that manages Kubernetes resources.

kubectl example:

``` bash
kubectl get pods
kubectl apply -f deployment.yaml
kubectl delete service my-service
kubectl describe pod my-pod
```

curl example:

``` bash
# Get pods in default namespace
curl -X GET https://kubernetes-api:6443/api/v1/namespaces/default/pods \
  -H "Authorization: Bearer YOUR_TOKEN" \
  --cacert /path/to/ca.crt

# Create a namespace
curl -X POST https://kubernetes-api:6443/api/v1/namespaces \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  --cacert /path/to/ca.crt \
  -d '{"apiVersion":"v1","kind":"Namespace","metadata":{"name":"test-ns"}}'

```

Python client library example:

``` python
from kubernetes import client, config

# Load kubeconfig
config.load_kube_config()

# Create API client
v1 = client.CoreV1Api()

# List all pods in default namespace
pods = v1.list_namespaced_pod(namespace="default")
for pod in pods.items:
    print(f"Pod: {pod.metadata.name}")
```


## Practical Commands 

One of the best ways to understand the Kubernetes API is to explore it using kubectl commands. The kubectl api-resources command shows you all the available resource types in your cluster, including their short names and API groups. The kubectl api-versions command lists all the API versions supported by your cluster, which helps you know the correct apiVersion to use in your YAML files.

To understand the structure of any Kubernetes resource, use the kubectl explain command followed by the resource type. This shows you all the fields available in a resource specification with descriptions of what each field does. If you want to see exactly what API calls kubectl is making behind the scenes, add the verbosity flag to any command with -v=8 or -v=9.

### Examples

``` bash
# List all available resources with details
kubectl api-resources
# Output shows: NAME, SHORTNAMES, APIVERSION, NAMESPACED, KIND

# See only core API resources
kubectl api-resources --api-group=""

# See resources from specific API group
kubectl api-resources --api-group=apps

# List with more details including verbs
kubectl api-resources -o wide

# List all API versions available
kubectl api-versions
# Output includes: v1, apps/v1, batch/v1, networking.k8s.io/v1, etc.


# Understand pod structure
kubectl explain pod
# Shows: apiVersion, kind, metadata, spec, status fields

# Drill down into specific fields
kubectl explain pod.spec
kubectl explain pod.spec.containers
kubectl explain pod.spec.containers.image
kubectl explain deployment.spec.replicas

# Get detailed field documentation
kubectl explain pod --recursive
kubectl explain service.spec.type

# See actual API calls being made (verbosity level 8)
kubectl get pods -v=8
# Shows: GET https://api-server:6443/api/v1/namespaces/default/pods

# Even more detailed output (verbosity level 9)
kubectl get pods -v=9
# Shows: Request headers, response headers, and body

# See API calls when creating resources
kubectl apply -f deployment.yaml -v=8

# See API calls when deleting resources
kubectl delete pod my-pod -v=8

# Check what would happen without actually doing it
kubectl apply -f deployment.yaml --dry-run=client -v=8
kubectl apply -f deployment.yaml --dry-run=server -v=8


# Explore different resource types
kubectl explain deployment
kubectl explain service
kubectl explain configmap
kubectl explain secret
kubectl explain statefulset

# Check what fields are required vs optional
kubectl explain pod.spec.containers.name
kubectl explain deployment.spec.replicas


```

## Conclusion

The API server is the heart of Kubernetes and serves as the foundation for everything that happens in your cluster. Every interaction, whether it's deploying an application, scaling a service, or checking the status of your workloads, flows through this central component. Understanding how the API is organized, how requests are processed, and how to interact with it effectively will make you much more capable when working with Kubernetes.

When you grasp how the API works, troubleshooting becomes easier because you understand the flow of requests and can identify where issues might occur. You'll be able to read documentation more effectively, write better YAML configurations, and build tools that integrate with Kubernetes. Whether you're preparing for certifications like KCNA or working as a platform engineer managing production clusters, knowledge of the Kubernetes API gives you the foundation to work confidently and efficiently with any Kubernetes environment.

## Further reading

- Official Kubernetes API concepts — [Kubernetes API concepts](https://kubernetes.io/docs/concepts/overview/kubernetes-api/) (official Kubernetes documentation)