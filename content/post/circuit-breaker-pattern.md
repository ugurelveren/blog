---
title: "Cloud Design Patterns: Circuit Breaker Pattern"
date: "2023-11-29"
author: "Ugur Elveren"
categories: ["Technical","Cloud Design Patterns"]
tags: ["circuit breaker pattern", "cloud design patterns", "cloud"]
description: "Understand the Circuit Breaker pattern, its implementation, and how it improves resiliency in cloud-based distributed systems."
---


The circuit breaker pattern stops a service from trying again to call another service when the previous attempts have failed multiple times. It's similar to electrical circuit breakers that automatically cut off the current when there's abnormal activity.

In a distributed environment, calls to remote resources may fail due to reasons such as application exceptions, timeouts, authentication issues, or overloaded systems. Usually, resilient cloud applications automatically fix these issues over time, and the calling application manages these errors using a retry pattern.

However, in some cases, these failures can persist, like when a service is down or systems are consistently overloaded. Excessive retries can create a cascading effect, overloading the same resource and impacting other resources as well. Repeated calls can impact both cost and performance.

At this stage, circuit breaker patterns come into play to address this issue. When the callee retries, it begins to assess the problem. If there's a specific error or if the error count surpasses the limit, circuit patterns activate, breaking the communication between the caller and the callee.

## Circuit Pattern Implementation Details

There are three main stages for the circuit breaker pattern.

### Closed

In a healthy state, the circuit breaker remains closed. It routes actions from source to target, mainly observing requests and logging their results.

### Open

If a specific error occurs in the previous request, such as a service being down or exceeding the error limit, the circuit breaker transitions to the open state. In this state, the circuit breaker prevents the continuation of the request, immediately returning it to the source application.

### Half Open

Half-Open state allows a few requests to test if a system has recovered from a failure before fully reopening. It's like cautiously peeking to see if things are back to normal.

You can use a timer, or more commonly, implement sampling between requests. Sampling involves letting a limited number of requests pass through. This helps evaluate if the system has recovered from a failure before completely reopening the circuit. It's a controlled method to check the system's health without overwhelming it with a full load of requests.

## When to use Circuit Breaker Pattern

The circuit breaker pattern serves as a digital guardian for our systems, aiding in various key aspects:

### Fault Handling

It prevents the application from attempting to invoke a remote service, particularly when there's a high likelihood of failure. This is crucial when dealing with external services or dependencies that may encounter issues. The circuit breaker helps avoid repeated attempts to use a failing service.

### Resilience

If you want your solution to gracefully handle temporary failures, consider implementing the circuit breaker pattern. Depending on your solution, you can trigger different events or take various actions based on the circuit breaker pattern's state.

### Load Management

The Circuit Breaker pattern assists in preventing overload on any dependency or system in our solution. This protection is valuable during high traffic or when downstream services are struggling.

## Issues and Considerations

### Code Bloating and Complexity

The Circuit Breaker pattern introduces some processing overhead to requests. Handling exceptions and deciding when to open or close the circuit breaker can be complex. Exception handling should be tailored to the specific application, and incorporating third-party dependencies may introduce additional logic into our code or solution. Dealing with exceptions that include error codes might contribute to an increase in code volume. For example, encountering a 404 Not Found error doesn't necessarily imply that the target resource is absent. Depending on the error code, you might need to decide whether to retry or initiate a 5-minute circuit closure. In some cases, developers might include the same error code in their code, and if you encounter a 404 with error code ER-12312, it might not require any action at all.

### Observability and Logging

A circuit breaker should record both failed and, if feasible, successful requests in its logs. System administrators should have the ability to monitor the system, and depending on factors such as load or failures, developers or system administrators may need to perform tuning or implement additional measures for optimization.

### Force or Manual Override

System administrators should have the capability to manually open or close the circuit breaker. Additionally, having the ability to reset the failure counter or restart the timeout timer can be beneficial for system management.

### Bottleneck

The circuit breaker might be accessible across multiple instances of an application. The implementation should not impede concurrent requests. If there is a request counter for the half-open state, it should not create a bottleneck. Additionally, if there is an additional dependency, such as a database or any other data sources, those sources should be scalable to accommodate the potential load.
