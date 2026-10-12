---
title: "Understanding SLAs: How to Define, Calculate, and Commit to a Service Level Agreement"
date: "2026-10-12"
author: "Ugur Elveren"
categories: ["Technical", "SRE", "DevOps"]
tags: ["SLA", "SLO", "SLI", "Reliability", "Observability", "SRE", "DevOps"]
description: "Learn how to define, calculate, and commit to realistic service level agreements by measuring user journeys, dependencies, redundancy, and fallbacks."
mermaid: true
mathjax: true
---

![Man writing on paper - Photo by Scott Graham on Unsplash](/images/man-writing-on-paper-sla.jpg)

An SLA is not only an engineering number. It is part of the product. Sales teams use it to win deals, and customers compare it when they choose between providers. A strong SLA can be the reason a customer signs, especially in enterprise deals where the buyer has to justify the choice to their own management. So the number is usually shaped by product managers, sales, and leadership as much as by engineers.

That is exactly why it often goes wrong. The business side wants a number that sells. The engineering side knows what the system can really do. When these two groups do not talk, the SLA ends up being picked rather than calculated. Someone chooses 99.9% because competitors offer it, or because it looks good in a sales deck. Then an outage happens, and nobody can say for sure whether the promise was broken, or whether it was ever realistic in the first place.

I think this is a bigger problem than it looks. Customers plan around the number you give them. They build their own products on top of yours, so if your number is wrong, theirs is wrong too. Missing an SLA also costs real money in credits and refunds, and it costs trust, which is harder to get back. On top of that, almost no service runs alone today. Your code can be perfectly healthy while your service still fails, because the database, the login provider, or some outside API is having a bad day. If you ignore those dependencies, your SLA only tells half the story.

A good SLA should not be a guess. It should come from a simple process: decide what "working" means for your users, measure it, understand what your service depends on, and then calculate what you can honestly promise. This gives the business side a number it can sell with confidence, and gives the engineering side a number it can actually deliver. In this article, I walk through that process with small examples and basic math. You do not need to be a reliability expert to follow along.

## What is an SLA?

SLA stands for Service Level Agreement. It is a promise from a provider to its customers about how well a service will work. A typical SLA says what is being measured, such as availability or response time. It sets a target, like 99.9% availability each month. It explains how the number is measured and what is left out. And it says what the customer gets if the target is missed, which is usually a credit on their bill.

That last part is what makes an SLA different from a simple goal.

> **An SLA is a contract. If you break it, you pay.**

Availability targets are usually described in "nines". The table below is well known, and you have probably seen it many times. It looks simple on paper, but keeping up with these numbers in real life is much harder than it looks. The percentages seem close to each other, yet the difference in allowed downtime is huge:

| Availability | Downtime per year | Downtime per month (30 days) |
|---|---|---|
| 99% | 3.65 days | 7.2 hours |
| 99.5% | 1.83 days | 3.6 hours |
| 99.9% | 8.76 hours | 43.2 minutes |
| 99.95% | 4.38 hours | 21.6 minutes |
| 99.99% | 52.6 minutes | 4.32 minutes |
| 99.999% | 5.26 minutes | 25.9 seconds |

Each extra nine gives you ten times less room for failure. In my experience, it also costs far more than ten times the effort to reach. Moving from 99.9% to 99.99% means you have about four minutes a month to notice a problem, find the cause, and fix it. That is not possible with a person reading alerts. You need automation, redundancy, and a lot of discipline.

## SLA vs. SLO vs. SLI

Before going into any calculations, it helps to clear up three terms that get mixed up all the time. I use all three in the rest of this article.

An SLI, or Service Level Indicator, is a measurement. For example, the percentage of requests that succeeded in under 300 milliseconds. It is just data. On its own, it does not promise anything.

An SLO, or Service Level Objective, is an internal goal for that measurement. For example, 99.9% of requests should be good over a rolling 28-day window. The SLO is for the engineering and product teams. When you miss it, nobody pays a penalty, but the team should stop adding features for a while and focus on reliability.

An SLA is the external promise, with consequences. For example, 99.5% monthly availability, or the customer gets a 10% credit. The SLA is for customers, sales, and legal.

The easiest way to remember it:

> **You measure the SLI. You aim for the SLO. You promise the SLA.**

> **❗ Important**
>
> Your SLO should always be stricter than your SLA. If your SLA is 99.5%, set your SLO at something like 99.9%. The gap between them is your safety margin. Missing the SLO is a warning sign. Missing the SLA costs money. If the two numbers are the same, you lose that warning entirely.

It is also worth saying that not every service needs an SLA. Many internal services never sign a contract with anyone. But every important service should have an SLO, because other teams rely on it whether there is a contract or not.

## How to calculate an SLA

The simplest way to calculate availability is to count time. You take the time the service was up and divide it by the total time.

$$
\text{Availability} = \frac{\text{Uptime}}{\text{Total time}}
$$

A 30-day month has 43,200 minutes. If the service was down for 30 minutes, availability is (43,200 − 30) / 43,200, which is 99.93%. That meets a 99.9% target, but not a 99.95% one.

Counting time works, but it hides a lot. A service can be "up" and still fail one request out of five. For this reason, most APIs and web services measure availability by counting requests instead. Google's Site Reliability Engineering (SRE) guidance calls this an event-based SLI, and the major cloud providers use the same approach in their own SLAs:

$$
\text{Availability} = \frac{\text{Good requests}}{\text{All valid requests}}
$$

If a service handled 10,000,000 requests in a month and 4,000 of them failed with a server error, availability is 99.96%.

The key to this formula is a clear definition of "good" and "valid". The common industry practice is to treat server errors (HTTP 5xx) as failures, because they are the service's fault. Client errors (HTTP 4xx), such as a 404 for a page that does not exist or a 401 for a wrong password, are usually removed from the valid requests completely. They are caused by the caller, so they should not count for or against the service.

> **💡 Tip**
>
> Measure as close to the user as possible, for example at the load balancer. That way, requests that never reach the service are still counted.

Once you have a target, you also have an error budget. This is simply the amount of failure your target allows. With a 99.9% target and 10 million requests a month, you can fail 10,000 requests, or be down for about 43 minutes. I find this idea very useful, because it turns reliability into something a team can plan with. If there is budget left near the end of the month, the team can ship features with more confidence. If the budget is gone, it is time to slow down and fix things.

## The fine print

The formulas above give you a raw number. But the contract decides what actually counts. When you read public SLAs from large providers, you will notice that they share many of the same clauses, and almost all of them work in the provider's favor. There is nothing illegal or unusual about this. Still, it means two SLAs that both say "99.9%" can mean very different things.

The biggest one is usually the definition of downtime. Many SLAs only count a minute as down if, for example, more than 5% of requests fail for five minutes in a row. Short spikes do not count. A small but steady error rate does not count. Slow responses rarely count. Often it is the provider's own monitoring that decides whether the service was down, so problems that only the customer can see are easy to miss.

Then come the exclusions. Planned maintenance, natural disasters, internet problems outside the provider's network, customer mistakes, and preview features are commonly left out. Some SLAs only apply if the customer runs the service in a certain way, such as two or more copies in different zones, or on a paid plan. Requests that were rejected because of rate limits are often removed from the count, which means turning traffic away during an overload does not hurt the number.

Finally, there is the remedy. In most cases the only thing a customer can get is a service credit, not a refund and not damages. Credits are usually tiered, for example 10% of the monthly fee below 99.9% and 25% below 99%, and they are capped at one month's fee for the affected service. The customer often has to file a claim within 30 or 60 days and provide proof. The credit comes as a discount on future bills, so a customer who leaves gets nothing.

To show how much this matters, let me use a sample SLA with typical terms. You will find similar wording in many real SLAs.

> **📄 Sample SLA**
>
> The service will be available 99.9% of the time per calendar month. A minute counts as downtime only if more than 5% of requests fail during that minute, and only when this lasts for at least five minutes in a row. Downtime during planned maintenance that was announced in advance is excluded.

Now imagine a month with two kinds of events. The first is planned: a one-hour maintenance window, announced in advance, during which the service was unavailable. The second is unplanned: six separate outages of four minutes each, and half an hour where 2% of requests failed.

From the customer's point of view, the service was fully down for 60 + 24 = 84 minutes. That is (43,200 − 84) / 43,200, or 99.81%, which clearly misses a 99.9% target.

Now apply the contract. The one-hour maintenance window is excluded, because it was planned and announced. Each four-minute outage is shorter than five minutes in a row, so none of them count. The 2% error rate is under the 5% limit, so it does not count either. The official SLA downtime for the month is zero, and the SLA is met.

If you are a provider, these clauses are reasonable. They protect you from costs you cannot control. But I would write them in plain words and publish them, and I would never use the contract version of the number to judge how my own service is doing. It is very possible to meet your SLA every month and still have unhappy customers. If you are a customer, read the downtime definition, the exclusions, the setup requirements, and the credit cap before you rely on any SLA. And measure the service yourself, which I come back to near the end of this article.

## Measuring an app that only half works

Real outages are rarely all or nothing. Checkout works but search is broken. Login works but images do not load. The API answers, but it takes eight seconds. A simple health check calls all of these "up", and I think that is misleading in both directions. It hides real pain from users, and it gives you no way to say how bad things actually were.

The approach that works best for me is to start with what users actually do. Write down the main user journeys, like logging in, placing an order, and searching, and decide how important each one is. Then give each journey its own SLI. A login counts as good if it succeeded and finished in under a second, for example. Once you measure each journey separately, you can see a partial outage for what it is.

There are a few ways to turn those separate numbers into something you can report. One is a weighted score. You give each journey a weight based on its importance, so that the weights add up to one, and then combine them. Say login has a weight of 0.3, placing an order 0.4, search 0.2, and two minor features 0.05 each. If everything works except search, and search only succeeds 60% of the time for an hour, the score for that hour is 0.3 + 0.4 + (0.2 × 0.6) + 0.05 + 0.05, which is 0.92. That hour counts as 92% available. It was not fully up and not fully down, and the number says so.

Another way is to use status levels, the kind you see on public status pages. The service can be fully working, slow, in a partial outage, or in a major outage. The SLA then says how much each level counts. A major outage might count fully as downtime, a partial outage as half, and slowness not at all.

A third way, and often the most useful for engineers, is to not combine anything. Each important journey simply gets its own SLO, like 99.95% for login and 99.5% for search. Each target then has a clear owner, and nobody has to argue about weights.

If your SLA is written in minutes, you can also mark each minute as good or bad. A minute might be bad if fewer than 95% of requests succeeded, or if responses were too slow. Availability is then the number of good minutes divided by all minutes. This catches partial problems that a basic health check would miss, and it is still easy to explain to a customer.

## Calculating an SLA when you depend on other services

So far, I have looked at a single service on its own. But a modern service rarely works alone. It relies on databases, caches, message queues, identity providers, other internal services, and external APIs. Your SLA depends on all of them, and the way they are connected sets a limit on what you can promise. There are two basic patterns: parts connected in a chain, and parts running side by side as backups.

### Parts in a chain

In a chain, a request passes through several parts one after another. Every part must work. If one part fails, the request fails.

Before looking at the formula, it helps to understand why the calculation works the way it does. Start with the numbers themselves. A percentage means "out of 100", so 99.9% is the same as 99.9 ÷ 100, or 0.999. It means the service works in 999 out of every 1,000 cases. This decimal form is needed because percentages cannot be multiplied directly. Multiplying 99.9 by 99.9 gives 9,980, which means nothing as an availability.

Now imagine 1,000,000 requests passing through two services, A and B, one after the other. Each service works 99.9% of the time:

{{<mermaid>}}
flowchart LR
    R["1,000,000 requests"] --> A["Service A<br/>99.9%"]
    A -->|"999,000 pass"| B["Service B<br/>99.9%"]
    B -->|"998,001 pass"| S(["998,001 succeed<br/>99.8001%"])
    A -.->|"1,000 fail"| F1["Failed"]
    B -.->|"999 fail"| F2["Failed"]
{{</mermaid>}}

In the end, 998,001 of the 1,000,000 requests succeed. That is 99.8001%.

The important detail is that service B never sees all the requests. It only sees the ones that service A already let through, and then it loses its own 0.1% of those. So the result is "99.9% of 99.9%", which is exactly 0.999 × 0.999. This is why the numbers are multiplied. Each part keeps only a share of what the previous part passed on, and every part in the chain pulls the total down a little more.

The general formula follows directly from this. Convert each percentage to a decimal and multiply them together:

$$
A_{\text{total}} = A_1 \times A_2 \times \dots \times A_n
$$

Using the same two services:

$$
0.999 \times 0.999 = 0.998001 \;\rightarrow\; \text{about } 99.8\%
$$

The result is lower than either part on its own, and it always will be. Each part you add brings its own chance of failure, so the total can only go down.

A typical chain shows how quickly this adds up. A request goes through an API gateway (99.95%), your service (99.9%), and a database (99.99%):

$$
0.9995 \times 0.999 \times 0.9999 = 0.9984 \;\rightarrow\; 99.84\%
$$

Every part meets 99.9% on its own, but the chain does not. With ten parts at 99.9%, the total drops to about 99.0%. Every hard dependency lowers the maximum you can promise.

<details>
<summary><strong>Why not just add up the downtime?</strong></summary>

You can also add up the downtime of each part. For high availability numbers, the result is almost the same. Two parts at 99.9% each allow 43.2 minutes of downtime per month. Together that is 86.4 minutes, or 99.8%. Multiplying gives 99.8001%.

The small difference comes from the time when both parts are down at once. Adding counts those minutes twice, while multiplying does not. At lower numbers the gap is bigger. Two parts at 90% give 80% by adding and 81% by multiplying.

</details>

### Planning versus reporting

The right method depends on what you are doing.

When you plan, you do not have real data yet. You are deciding what you can promise. In this case, multiply the targets of each part. This is the standard method.

When you report on a past month, use real measurements instead of a formula. The best source is an end-to-end measurement from the user's side, such as the share of failed user requests. It already includes overlapping outages, retries, and fallbacks.

If you only have downtime records for each part, merge the outages that overlap before you add them up:

```
Part A down:   10:00 – 10:30
Part B down:   10:20 – 10:40
Service down:  10:00 – 10:40  →  40 minutes, not 50

Availability = (43,200 − 40) / 43,200 = 99.91%
```

> **Multiply to plan. Measure to report.**

If the measured number is regularly lower than the planned one, a dependency is performing worse than expected, or one is missing from your calculation.

### Parts running as backups

Redundancy works in the opposite direction. If you run two or more copies and the request succeeds when any one of them works, the service only fails when all copies fail together.

The same request-counting idea explains how this works. Imagine 1,000,000 requests sent to Copy 1. When Copy 1 fails, the request is sent to Copy 2 as a backup. Each copy works 99.9% of the time:

{{<mermaid>}}
flowchart TD
    R["1,000,000 requests"] --> C1["Copy 1<br/>99.9%"]
    C1 -->|"999,000 succeed"| S(["999,999 succeed in total<br/>99.9999%"])
    C1 -.->|"1,000 fail, sent to the backup"| C2["Copy 2<br/>99.9%"]
    C2 -->|"999 succeed"| S
    C2 -.->|"1 fails"| F["1 request fails<br/>(both copies failed)"]
{{</mermaid>}}

Copy 2 only sees the 1,000 requests that Copy 1 could not handle, and it fails just 0.1% of those. That leaves a single failed request out of 1,000,000. In a chain, every part takes something away. With backups, every extra copy gives the request another chance.

So instead of multiplying the success rates, you multiply the failure rates. A copy at 99.9% fails 0.1% of the time, which is 0.001. The chance that all copies fail together is the failure rates multiplied, and the availability is whatever is left:

$$
A_{\text{total}} = 1 - (1 - A_1) \times (1 - A_2) \times \dots \times (1 - A_n)
$$

For the two copies above:

$$
1 - (0.001 \times 0.001) = 0.999999 \;\rightarrow\; 99.9999\%
$$

This matches the 999,999 successful requests in the diagram.

> **⚠️ Warning**
>
> This number assumes the copies fail independently. In practice, they often fail together. The same faulty release reaches both, the same configuration change breaks both, or both rely on the same DNS provider. Treat this result as a best case, not a planning number.

### Mixed systems

Most real systems combine chains and backups. Calculate them in two steps. First, reduce each group of copies to a single number. Then multiply along the chain.

For example, a gateway (99.95%) sits in front of two copies of a service (99.5% each), and both copies use one database (99.99%):

{{<mermaid>}}
flowchart LR
    R["Requests"] --> G["API Gateway<br/>99.95%"]
    G --> S1["Service copy 1<br/>99.5%"]
    G --> S2["Service copy 2<br/>99.5%"]
    S1 --> D["Database<br/>99.99%"]
    S2 --> D
{{</mermaid>}}

The gateway and the database form a chain, but the two service copies are backups for each other. So the first step is to treat the two copies as one part. Each copy fails 0.5% of the time, which is 0.005:

$$
\text{Two copies} = 1 - (0.005 \times 0.005) = 0.999975 \;\rightarrow\; 99.9975\%
$$

After this step, the system is a simple chain of three parts:

{{<mermaid>}}
flowchart LR
    R["Requests"] --> G["API Gateway<br/>99.95%"]
    G --> P["Service pair<br/>99.9975%"]
    P --> D["Database<br/>99.99%"]
    D --> T(["Total: about 99.94%"])
{{</mermaid>}}

The second step is to multiply along the chain, exactly as before:

$$
\text{Full chain} = 0.9995 \times 0.999975 \times 0.9999 = 0.9994 \;\rightarrow\; \text{about } 99.94\%
$$

Two weak copies become a strong pair, and the gateway is now the weakest part of the chain. This is a useful result on its own. If you want to improve this system, adding a third service copy will barely help. Making the gateway more reliable will.

### The rule to remember

> **❗ Important**
>
> Your maximum availability is roughly your own availability multiplied by that of each hard dependency. Backups raise it, and so do fallbacks, which I cover in the next section. Shared failures lower it. Whatever the result is, do not promise customers more than that.

> **📝 A note on retries**
>
> Retries help with brief, random errors, such as a single dropped connection, because a second attempt usually works. They do not help during a real outage, when every attempt fails. Too many retries can even make an outage worse by flooding a service that is already struggling. So retries are not a way to raise the SLA. They protect it from small errors, and they should always be limited, with a growing delay between attempts.

## Hard and soft dependencies

Not every dependency matters in the same way. A hard dependency is one your service cannot work without. If it fails, your users see the failure. The main database is a typical example, and so is the login provider. A soft dependency is one your service can live without, maybe in a reduced form. Recommendations, analytics, a cache that can fall back to the database, or a feature flag service with sensible defaults are all usually soft.

The difference matters a lot for your SLA. Hard dependencies get multiplied into your availability, as shown in the previous section. Soft dependencies do not lower your core availability at all. They only affect how well your service works when it is degraded, which is the "half working" case I described earlier. So getting this classification right can change your calculated SLA by a whole nine.

In most cases, what makes a dependency soft is a fallback. A fallback is a backup answer your service returns when a dependency fails. It might be a cached value, a default setting, or a general list instead of personal recommendations. The user may get a slightly reduced experience, but the request still succeeds.

A fallback works much like a backup copy. Imagine a recommendations service that works 99% of the time, and a cached list that works 99.9% of the time. When the service fails, the cached list is shown instead:

{{<mermaid>}}
flowchart TD
    R["1,000,000 requests"] --> D["Recommendations service<br/>99%"]
    D -->|"990,000 succeed"| S(["999,990 succeed in total<br/>99.999%"])
    D -.->|"10,000 fail, use the fallback"| F["Cached list<br/>99.9%"]
    F -->|"9,990 succeed"| S
    F -.->|"10 fail"| X["10 requests fail"]
{{</mermaid>}}

The dependency handles most requests on its own. Of the requests it fails, the fallback rescues almost all of them. The formula follows the same logic:

$$
A_{\text{effective}} = A_{\text{dep}} + (1 - A_{\text{dep}}) \times P_{\text{fallback}}
$$

$$
0.99 + (0.01 \times 0.999) = 0.99999 \;\rightarrow\; 99.999\%
$$

A dependency that works 99% of the time now behaves like one that works 99.999% of the time. This is why fallbacks are one of the cheapest ways to raise an SLA. There is one condition, though. A fallback only counts if the reduced answer is acceptable for that user journey. Showing a cached product list is fine. Showing an old account balance probably is not.

One thing I learned is that you should decide this for each user journey, not for the service as a whole. A payment provider is a hard dependency for checkout. For someone who is only browsing, it does not matter at all.

The first step is a simple question. For each dependency, ask yourself what happens to each journey if it fails or hangs for ten minutes. If the journey fails, the dependency is hard. If the journey still works, maybe a bit worse, it is soft. If the honest answer is "I'm not sure", treat it as hard until you have proven otherwise.

The second step is to look at the code, because a dependency is only soft if the code makes it soft.

> **⚠️ Watch out for missing timeouts**
>
> A "soft" dependency that hangs without a timeout will hold on to threads or connections until your whole service runs out of them. At that point, it is not soft anymore.

Check that every call has a timeout. Check whether there is a circuit breaker, which stops calling a broken service for a while, and a fallback, which returns something useful instead of an error. Check whether the call could happen asynchronously through a queue, off the user's path. And check whether the service needs the dependency at startup. If it cannot start without it, that dependency is hard during every deploy and every scale-up.

The third step is to look at traces. Distributed tracing, for example with OpenTelemetry, shows exactly which calls happen during each request, and whether an error in one call makes the whole request fail. It often reveals dependencies nobody knew about.

The last step, and the only one that gives you real proof, is to break things on purpose. In a test environment first, and later carefully in production, block the dependency, slow it down, or make it return errors. Then watch your user journeys. If they stay within their targets, the dependency is soft. If they do not, it is hard, or it was meant to be soft and the fallback is missing. That second case is simply a bug, and now you have found it before your customers did.

Whatever you find, write it down. I keep a short record for each service that lists every dependency, which journeys it affects, whether it is hard or soft, what the fallback and timeout are, what the vendor promises, and what I have actually measured. This record is the input for the final calculation.

## Tools for tracking dependencies and calculating your SLA

To calculate an SLA for each service, you need three things: a map of which service calls which, the type of each dependency, and the real measured availability of each one. Tools can do most of the work for the first and the third. The classification still needs human judgment and the testing I described above.

Let me start with outside services. A vendor's SLA is a promise, not a measurement, and as the fine print section showed, it may not match what you actually experience. Status page collectors like StatusGator and IsDown gather vendor status pages in one place and alert you when something changes. That is a good start, but it only tells you what the vendor chooses to report. Synthetic monitoring goes further. Tools like Checkly, Pingdom, Datadog Synthetics, Grafana Synthetic Monitoring, the self-hosted Uptime Kuma, or the Prometheus Blackbox Exporter send test requests to the vendor's API from your own locations, so you get your own availability numbers. For network problems between you and the vendor, tools like ThousandEyes and Catchpoint can show where along the path things go wrong.

The most accurate source, though, is your own code. I recommend wrapping every outside call in a small client that records whether the call succeeded and how long it took. OpenTelemetry makes this easy, and a service mesh can collect the same data for you. That metric becomes the SLI for the dependency, and you can compare it directly with the vendor's promise.

Inside a Kubernetes cluster, there are several good ways to build the dependency map automatically. A service mesh like Istio with Kiali, or Linkerd, sees every call between services and draws a live map with error rates and response times on each connection. eBPF-based tools like Cilium Hubble, Pixie, Coroot, and Caretta watch network traffic at the kernel level and build the map without any code changes. Coroot can also track SLOs. Tracing tools such as Jaeger, Grafana Tempo, and Zipkin build the map from real requests. Commercial platforms like Datadog, Dynatrace, New Relic, Elastic APM, and Honeycomb do all of this out of the box. And service catalogs like Backstage, Port, and OpsLevel let teams declare their dependencies by hand. I like comparing the declared list with the observed map, because the differences are usually dependencies that nobody wrote down.

For the SLOs themselves, OpenSLO is an open format for writing SLOs as code. Sloth and Pyrra turn simple SLO definitions into Prometheus rules and alerts. Managed options include Grafana SLO, Datadog SLOs, Nobl9, Dynatrace, and the monitoring services of the big cloud providers.

With these pieces in place, the calculation for each service becomes a repeatable process. First, build the dependency map with a mesh, eBPF, or tracing tool, and check it against your service catalog. Then mark each dependency as hard or soft for each user journey. Measure the real availability of each dependency over the same window as your SLA, for example 30 days, and only fall back to the vendor's published number when you have no data yet. Then calculate each journey:

$$
A_{\text{journey}} = A_{\text{self}} \times \prod A_{\text{hard}} \times \prod \Big[ 1 - \prod (1 - A_{\text{copy}}) \Big] \times \prod \Big[ A_{\text{dep}} + (1 - A_{\text{dep}}) \times P_{\text{fallback}} \Big]
$$

The symbol $\prod$ simply means "multiply all of them together". So the formula reads like this: your own availability, times every hard dependency, times every group of backup copies, times every dependency that has a fallback. Each part uses the formulas from the earlier sections.

Soft dependencies that do not affect the journey are simply left out. If you need a single number for the whole service, combine the journeys with weights, as described in the section on apps that only half work. Set your SLO at or below the number you calculated, and your SLA below your SLO.

Do not treat this as a one-time exercise. Dependencies change with almost every deploy. The best setup I know automates the map, the measurements, and the calculation, and raises an alert when the achievable availability drops below what you have promised.

To make this practical, it helps to write your SLOs down in a standard format. OpenSLO is an open, vendor-neutral specification for this. It describes SLIs and SLOs in YAML files that can live in version control next to your code, and several SLO tools can read them.

Here is an example for the "place an order" user journey. It follows the industry practice described earlier. It measures the journey at the edge, at the ingress controller where user requests enter the system. It treats server errors as failures, and it removes client errors from the valid requests.

<details>
<summary><strong>Show the OpenSLO example (YAML)</strong></summary>

```yaml
apiVersion: openslo/v1
kind: SLO
metadata:
  name: place-order-availability
  displayName: Place order availability
spec:
  description: Customers can place an order successfully.
  service: web-shop
  indicator:                       # the SLI: what is measured
    metadata:
      name: place-order-success-ratio
      displayName: Successful order requests
    spec:
      ratioMetric:
        counter: true
        good:                      # requests that succeeded
          metricSource:
            type: Prometheus
            spec:
              query: sum(nginx_ingress_controller_requests{path="/api/orders", status!~"[45].."})
        total:                     # all valid requests (client errors removed)
          metricSource:
            type: Prometheus
            spec:
              query: sum(nginx_ingress_controller_requests{path="/api/orders", status!~"4.."})
  timeWindow:                      # the SLO: the period and the target
    - duration: 28d
      isRolling: true
  budgetingMethod: Occurrences
  objectives:
    - displayName: Orders succeed
      target: 0.999
```

</details>

The file shows the difference between the terms very clearly. The `indicator` block is the SLI. It only describes what is measured, which is good order requests divided by all valid order requests. The `timeWindow` and `objectives` blocks turn it into an SLO, with a target of 99.9% over a rolling 28 days. The SLA does not appear in the file at all, because it is a contract and not a measurement. Following the rule from earlier, the SLA for this journey would be set lower than the SLO, for example at 99.5%.

You can write one file like this for each important user journey, and one for each internal service that other teams depend on. Together, they give you the measured numbers you need for the calculation above.

## Final thoughts

An SLA is easy to write and hard to get right. The number itself is the least interesting part. What matters is knowing where it comes from. That means measuring what users actually experience, including slow responses and partial failures. It means reading the fine print, whether you are writing the SLA or signing it. And it means taking an honest look at everything your service depends on, because hard dependencies quietly pull your ceiling down while redundancy and good fallbacks push it back up.

If you take one thing from this article, I hope it is this:

> **Do not pick your SLA. Calculate it.**

Map your dependencies, measure them yourself, test your fallbacks by breaking things on purpose, and keep your internal targets stricter than your promises. When you do that, the next outage stops being a debate about whether the SLA was broken. You will already know.
