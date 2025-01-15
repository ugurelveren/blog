---
draft: true
date: "2024-02-16"
title: 'What is Cloud Native?'
categories: ["Technical", "Cloud Design Patterns"]
---

This is one of those topics where everyone has a slightly different answer and most of them are correct. That's the beauty of computer science: there's rarely a single correct answer. Because it's difficult to cover all these perspectives in one article, I want to share my perspective here. For other viewpoints, you can explore online resources and read different takes on the subject.

Before diving into cloud-native development and design, we need to first understand what software design and software architecture are.

### Software Design
Software design is the process of planning and defining how individual components or modules of a software system will work. It focuses on the detailed implementation of features, algorithms, data structures, and user interfaces, ensuring each module is functional, reusable, and integrates seamlessly with others. It operates at a lower level, producing outputs like class diagrams, flowcharts, and pseudocode that directly guide coding efforts.

### Software Architecture
Software architecture is the high-level blueprint of a software system, defining its structure, components, and their interactions. It focuses on overarching decisions like scalability, performance, reliability, and technology choices, ensuring the system aligns with business goals and is adaptable to future needs. Outputs include system architecture diagrams, deployment strategies, and communication flows, serving as a foundation for software design and development.

### Relation Between Software Architecture and Design
The relationship between software architecture and software design is collaborative and hierarchical. Architecture provides the high-level structure and guiding principles, while design focuses on the detailed implementation of those principles within individual components. Software architecture defines the overall system blueprint, including how components interact, scalability, and technology choices, creating constraints and opportunities for the design process. Software design, in turn, implements the architectural vision by detailing how each module will function, including algorithms, data structures, and workflows. Together, they ensure the system is both cohesive at a macro level (architecture) and functional at a micro level (design).

### Bridging Architecture and Design in Cloud-Native Development
Understanding both software architecture and design is a foundation for cloud-native development because they address different but complementary aspects of building cloud-native systems. Cloud-native architecture focuses on the overall structure of the system, such as adopting microservices, using containers, and leveraging orchestration tools like Kubernetes. Meanwhile, cloud-native design deals with the specific implementation details of each module or service, including API design, resilience patterns, and error handling. Together, they ensure that the system is both scalable and robust at a high level and efficient and reliable in its individual components.

### What is Cloud-Native Development?
Eventually we need to ask this question right. What is cloud native? I will cheat for this answer. There is a really good explanation of this question from [Cloud Native Foundation](https://www.cncf.io/) in 23 different languages. [Source](https://github.com/cncf/toc/blob/main/DEFINITION.md), 

> Cloud native practices empower organizations to develop, build, and deploy workloads in computing environments (public, private, hybrid cloud) to meet their organizational needs at scale in a programmatic and repeatable manner. It is characterized by loosely coupled systems that interoperate in a manner that is secure, resilient, manageable, sustainable, and observable.

It focuses on creating scalable, resilient, and flexible systems using modern practices such as microservices, containers, DevOps, and continuous delivery. Applications are designed to run in distributed environments, ensuring they can scale dynamically, recover from failures quickly, and adapt to changing demands. By embracing cloud-native development, organizations can deliver software faster, optimize resource usage, and respond more effectively to business needs.

If we go to the first description from their github page from May18,2018, there was a completely different description for this. 

> Cloud native technologies empower organizations to build and run scalable applications in modern, dynamic
environments such as public, private, and hybrid clouds. Containers, service meshes, microservices, immutable
infrastructure, and declarative APIs exemplify this approach.
These techniques enable loosely coupled systems that are resilient, manageable, and observable. Combined with
robust automation, they allow engineers to make high-impact changes frequently and predictably with minimal
toil.

Lets focus on the latest answer of Cloud Native foundation and understhat what they mean with answer.

#### Loosely Coupled Systems
Loosely coupled systems refer to a design approach where the components of the systems interact with each other in a way that minimizes dependencies. There are various way to communicate modules with eachother however most popular two ways are message queues and api. But it can be file based comunicaton, gRPC, service mesh or something else. 

This sentence describes the key attributes of a well-designed cloud-native system (or modern software architecture). Let's break it down:

Loosely Coupled Systems:

The components of the system are independent and interact with each other through well-defined interfaces (like APIs).
Changes or failures in one component don't directly affect the others, allowing for easier updates and better fault tolerance.
Interoperate:

These systems can work together seamlessly, often leveraging standardized communication protocols (like HTTP or gRPC) or messaging systems (like Kafka or RabbitMQ).
Secure:

The system ensures data confidentiality, integrity, and access control, often by employing encryption, authentication, and authorization mechanisms.
Resilient:

The system can recover from failures gracefully without significant impact on performance or user experience. For instance, it may include failover strategies, retries, or redundant components.
Manageable:

The system is designed to be easily operated and maintained, often using tools like monitoring dashboards, CI/CD pipelines, and automated deployment scripts.
Sustainable:

The system can handle long-term growth, changes, and evolving requirements without significant rework. This includes scalability and efficient resource use.
Observable:

The system provides visibility into its internal states and behaviors through logging, metrics, and tracing. This helps operators diagnose issues, understand performance, and ensure smooth operation.