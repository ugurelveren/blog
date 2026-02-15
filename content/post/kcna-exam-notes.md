---
title: "KCNA exam notes"
date: "2026-02-15"
slug: "kcna-exam-notes"
description: "Simple KCNA exam notes that explain the exam scope and core Kubernetes resources."
summary: "This post explains the KCNA exam and covers key Kubernetes resources such as Pod, Deployment, StatefulSet, DaemonSet, Job, and CronJob."
categories: ["technical"]
tags: ["kcna","kubernetes","cloud-native"]
author: "Ugur Elveren"
toc: true
reading_time: 5
series: "KCNA"
layout: "post"
---

Two weeks ago there was a discount on Linux Foundation exams, so I bought the KCNA (Kubernetes and Cloud Native Associate) exam because it looked like a good starting point. I wanted a short, focused review about 30 pages of notes to study before the exam, but I could not find a reliable one, so I made my own.

I will publish a series of posts about KCNA (and later CKA) as a short study guide. In this first post I explain what the KCNA exam covers, how it works, and how to prepare. Later posts will cover each topic with short explanations and key points. I will use simple language and keep the content short and practical.

## What is KCNA exam

The official name is the Kubernetes and Cloud Native Associate exam. It is a beginner level exam for Kubernetes. The exam is offered by the Linux Foundation in partnership with the Cloud Native Computing Foundation. It is a multiple choice exam with 60 questions and a 90 minute time limit. The exam is online and proctored.

As the Linux Foundation states, this is a beginner exam. The main goal is to check your understanding of Kubernetes, container orchestration, and the broader cloud native ecosystem. If you know these topics and have basic Kubernetes skills, you should be able to pass.

I have heard people say the exam is not useful and that they do not want to pay for it. Some think the Linux Foundation is only trying to earn money with paid exams. I do not agree with that view. This exam is different. It is an entry level test for the Kubernetes ecosystem and a simple way to measure basic knowledge of these topics.

## KCNA Curriculum

As I said, I will write a series of articles for this exam and follow the official curriculum. First, let's look at the exam curriculum.

* [Curriculum](https://github.com/cncf/curriculum/blob/master/KCNA_Curriculum.pdf)

* Kubernetes Fundamentals 44%
  * Kubernetes Core Concepts
  * Administration
  * Scheduling
  * Containerization
* Container Orchestration 28%
  * Networking
  * Security
  * Troubleshooting
  * Storage
* Cloud Native Application Delivery 16%
  * Application Delivery
  * Debugging
* Cloud Native Architecture 12%
  * Observability
  * Cloud Native Ecosystem and Principles
  * Cloud Native Community and Collaboration

As you can see, most of the exam focuses on Kubernetes. If you read the official documentation on [kubernetes.io](https://kubernetes.io/docs/), you can answer many of the questions. We are not writing a long book here. I will not provide an information dump or a full summary for this exam.

## Kubernetes Fundamentals

I think this topic should be a top level section rather than a subsection, but I have not decided to split it yet. For now, let us focus on one topic at a time. What is Kubernetes?

Kubernetes is a container orchestration platform that automates deployment, scaling and management of containerized applications. Google built an internal cluster manager called Borg to run large services such as Gmail, Search and YouTube. The lessons from Borg led to the first version of Kubernetes in 2013 and it was shown at DockerCon in 2014.

In 2015 Google donated Kubernetes to the Cloud Native Computing Foundation and it became the first graduated project. Before Kubernetes, Apache Mesos and Docker Swarm were popular choices for orchestration. From around 2018 Kubernetes grew rapidly and became the industry standard. Many CNCF projects now integrate with or relate to Kubernetes.

## Kubernetes resources

Now that we have defined Kubernetes and reviewed its history, let us look at Kubernetes resources. Kubernetes resources are the basic building blocks that represent the desired state of the cluster. You can think of them as objects stored in the Kubernetes API. There are many types of Kubernetes objects. They describe which containerized applications run, what resources those applications can use, and the policies that control their behavior.

Resources can be grouped in different ways. A useful approach is to group them by function.

### Workload and Compute Resources

This group covers compute resources such as Pod, Deployment, StatefulSet, DaemonSet, Job and CronJob. Each resource has a different responsibility. I will describe them one by one and explain what they do.

#### Pod

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

#### Deployment

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

##### Deployment strategies

There are several deployment strategies. Two common strategies that Kubernetes supports by default are rolling updates and recreate. Other strategies usually need extra tools or custom setup.

* **rolling updates**
  Rolling updates replace old Pods with new Pods in small steps. The controller creates new Pods, waits until they are ready, and then removes old Pods. This helps reduce downtime.

* **recreate**
  The recreate strategy removes all current Pods before it creates new Pods. This strategy is simple, but it causes downtime while new Pods start.

#### StatefulSet

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

##### StatefulSet vs Deployment

| Feature | StatefulSet | Deployment |
|---------|-------------|------------|
| **Pod Identity** | Stable, predictable (web0, web1) | Random (webabc123) |
| **Pod Order** | Sequential creation/deletion | Parallel |
| **Storage** | Persistent per Pod | Shared or ephemeral |
| **Network ID** | Stable hostname | Random hostname |
| **Use Case** | Stateful apps (databases) | Stateless apps (web servers) |
| **Scaling** | Ordered | Parallel |

#### DaemonSet

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

#### Job

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

#### CronJob

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

## Summary

In this post, we reviewed what the KCNA exam is and what topics it covers. We also looked at core Kubernetes resources that are important for the exam, including Pod, Deployment, StatefulSet, DaemonSet, Job, and CronJob. The goal is to build a clear foundation before moving to deeper topics. In the next posts, we will continue each area with short and practical notes.