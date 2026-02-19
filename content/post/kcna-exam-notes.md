---
title: "KCNA Exam Notes"
date: "2026-02-14"
slug: "kcna-exam-notes"
description: "Simple KCNA exam notes that explain the exam scope and core Kubernetes resources."
categories: ["technical","kubernetes"]
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

As I said, I will write a series of articles for this exam and follow the official curriculum. First, let's look at the exam [curriculum](https://github.com/cncf/curriculum/blob/master/KCNA_Curriculum.pdf).

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


## Summary

In this post, we reviewed what the KCNA exam is and what topics it covers. The goal is to build a clear foundation before moving to deeper topics. In the next posts, we will continue each area with short and practical notes.