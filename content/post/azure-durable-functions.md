---
title: "Azure Durable Functions"
date: "2023-06-29"
author: "Ugur Elveren"
categories: ["Technical","Cloud"]
tags: ["Azure Functions", "serverless", "cloud"]
description: "Explore Azure Durable Functions and learn how to build long-running workflows in a serverless computing environment."
---

## Azure Functions and Azure Durable Functions

Microsoft Azure is a constantly expanding collection of cloud services. Among these services, Azure Functions and Azure Durable Functions are critical in enabling serverless computing. In this article, we will look at Azure Functions and Azure Durable Functions, distinguish between the two, and learn about the key concepts surrounding Azure Durable Functions.

### What is an Azure Function?

Azure Functions is a serverless computing service designed to effortlessly run small code snippets (functions) without any concern about the underlying infrastructure. This cloud-based solution empowers developers to focus solely on their code while leaving the infrastructure management worries behind.

Various events, such as HTTP requests, database modifications, or predefined schedules can trigger these functions. The brilliance of Azure Functions lies in its ability to optimize resource utilization by executing only in response to specific events, ultimately resulting in a cost-effective solution for your computing needs.

### What is an Azure Durable Function?

Azure Durable Functions, an advanced extension of Azure Functions, opens up exciting possibilities for developers to build stateful functions within a serverless computing environment. Unlike regular Azure Functions, which are stateless and do not retain any memory of previous calls, Durable Functions can remember the state between function invocations.

This stateful capability empowers developers to define and manage long-running workflows, complete with checkpointed intermediate states. This feature ensures that even if the function gets interrupted due to factors like a system reboot, it can seamlessly resume its execution from the exact point where it left off. This resilience and continuity in processing make Azure Durable Functions a powerful tool for handling complex tasks and orchestrating sophisticated operations in the cloud.

### What is the Difference Between Azure Function and Azure Durable Functions?

- **State**: Azure Functions are stateless, meaning they don't retain information between executions. In contrast, Azure Durable Functions are stateful, enabling them to maintain information between different function calls.

- **Long-Running Tasks**: Durable Functions are designed for long-running tasks, often comprising multiple steps, and can even be paused and resumed. Regular Functions are designed for more immediate, quick responses.

- **Complex Workflows**: Durable Functions allow for more complex workflows, including chaining functions together, running them in parallel, and more. This isn't readily supported in regular Azure Functions.

- **Resiliency**: Durable Functions provide built-in support for error handling, retries, and compensation logic, making them more suitable for complex operations that require a higher level of robustness.

### Durable Function Types and Features

There are currently four durable function types in Azure Functions: activity, orchestrator, entity, and client. The rest of this section goes into more detail about the types of functions involved in an orchestration.

#### Orchestrator Functions

Orchestrator Functions are the core building blocks of Azure Durable Functions. They act as the brain of the workflow, defining the execution logic and coordinating the interactions between other function types. Orchestrators are responsible for guiding the flow of activities and sub-orchestrations based on input parameters and external events. They maintain the state of the workflow, making it resilient to failures and enabling efficient error handling.

#### Activity Functions

Activity Functions represent individual units of work within an Azure Durable Function workflow. These functions perform specific tasks or operations, such as data processing, API calls, or database interactions. Activity Functions are designed to be stateless and idempotent, allowing them to be executed multiple times without impacting the overall result.

#### Entity Functions

Entity Functions are a unique feature of Azure Durable Functions, allowing developers to create stateful interactions within a serverless environment. Durable Entities enable the maintenance of long-lived states, providing a robust solution for scenarios where stateful interactions are essential. Each entity instance acts as an independent actor with its own state, and function calls to the entity are automatically routed and serialized to ensure data consistency.

#### Client Functions

Client Functions, also known as External HTTP Triggers, allow external systems to initiate and interact with Azure Durable Functions. By exposing HTTP endpoints, developers can trigger workflows, pass input data, and receive output responses from the orchestrator. Client Functions facilitate the integration of Durable Functions with other applications and services, making them accessible from outside the Azure ecosystem.

### Application Patterns

Azure Durable Functions provide a powerful framework for building serverless applications with long-running, stateful workflows. Let's explore each of the Azure Durable Function application patterns in detail.

#### Function chaining

Function chaining is the simplest and most common pattern in Azure Durable Functions. It involves chaining multiple functions together to create a workflow. Each function's output becomes the input for the next function in the sequence. This pattern is ideal for linear workflows, where each step depends on the successful completion of the previous one.

**Use case example**: In an e-commerce application, you might have a function to validate an order, then a function to process payment, and finally, a function to send a confirmation email.

#### Fan Out/Fan In

Fan out/fan in is a pattern where a single trigger initiates multiple parallel tasks (fan-out) that run concurrently. Once all the parallel tasks are completed, the workflow consolidates the results and continues with the next step (fan-in). This pattern is useful when you have a single input that needs to be processed by multiple independent tasks.

**Use case example**: In a data processing application, you could fan out to multiple functions to process data from different sources in parallel. Then, you would fan in to aggregate the results into a single output.

#### Async HTTP APIs

This pattern is used to create asynchronous HTTP APIs that return immediately with a status or correlation ID, while the actual processing continues in the background. Clients can later query the status or use the correlation ID to get the results when they are ready.

**Use case example**: A file conversion API that accepts a file, returns a correlation ID, and then performs the conversion in the background. The client can use the correlation ID to check the conversion status and download the converted file when it's ready.

#### Monitor

The monitor pattern allows you to define a function that waits for external events or triggers. It's a way to introduce a delay in the workflow until a specific condition is met or an external signal is received.

**Use case example**: A social media sentiment analysis application that waits for a specific number of user mentions before triggering the sentiment analysis workflow.

#### Human Interaction

This pattern is used when a workflow requires human intervention or approval at some point. The workflow can pause and wait for human input before continuing.

**Use case example**: An expense approval process that involves human reviewers who can approve or reject an expense report.

#### Aggregator (Stateful Entities)

The aggregator pattern involves using stateful entities to maintain and aggregate state across multiple function calls. Stateful entities are durable entities in Azure Durable Functions, which allow you to maintain state across function invocations in a scalable manner.

**Use case example**: A real-time voting application where you need to keep track of votes for different options in a poll. Durable entities can be used to store and update the vote counts.

In conclusion, Microsoft Azure Functions and Azure Durable Functions offer developers powerful tools for building serverless applications. Azure Functions provide easy-to-use serverless computing, while Azure Durable Functions introduce stateful capabilities, enabling long-running and resilient workflows. By understanding their differences and utilizing the application patterns, developers can create innovative, efficient, and scalable solutions in the cloud. With ongoing advancements in the Azure ecosystem, these serverless technologies will continue to play a key role in cloud application development.

#Tech
