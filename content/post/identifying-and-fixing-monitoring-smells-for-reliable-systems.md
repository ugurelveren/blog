---
title: "Spotting and Fixing Monitoring Smells: A Guide to Reliable Systems"
date: "2024-11-18"
author: "Ugur Elveren"
categories: ["Technical","SRE", "DevOps"]
tags: ["Monitoring", "Observability", "Monitoring Smells", "SRE", "DevOps"]
description: "Learn how to identify and fix common monitoring smells that can hurt your system's reliability. Discover actionable strategies for smarter alerts, better visibility, and faster problem resolution to keep your production systems running smoothly."
mastocomments:
  host: hachyderm.io
  username: ugur
  id: 113522002355892638
---


Keeping production systems healthy and reliable is a challenge. Are your services running without problem? During high-traffic periods, can your system handle the load without bottlenecks or failures? What about dependencies? Is everything working fine with third-party depencies or is there an outage on cloud service provider? These are everyday challenges for **DevOps** and **SRE** teams alike.

Just like messy code gives clues about deeper issues (code smells), monitoring systems can have **"monitoring smells."** when something isn't right. These are signs that your monitoring setup isn't as good as it should be. While I won't be diving into how to build the perfect monitoring system. This article will explain what these smells are, how to notice them, and how to fix them.

### What is observability and monitoring?

When it comes to system monitoring, two terms often come up: **`monitoring`** and **`observability`**. Though they're closely related, each plays a unique role in how we understand and maintain system health.

#### Monitoring
**`Monitoring`** tracks system health using key data like CPU usage, response times, or error rates. When something goes wrong, it alerts you. For example, if your system slows down or crashes, monitoring tools let you know so you can act quickly. CPU usage reaches critical levels, monitoring tools alerts us, prompting immediate action manually or automatically.  By focusing on metrics, we're able to maintain stability, minimize downtime, and respond quickly when issues arise. 

#### Observability
**`Observability`** goes deeper. It helps you understand why something went wrong by using logs, traces, and metrics. Observability tools help engineers solve problems by providing detailed clues about what's happening inside the system.

If any question about the system's health can't be answered directly, these observability solutions guide the investigation, giving engineers clues and patterns that lead to root causes. Observability, in essence, equips engineers not just to detect problems but to diagnose and resolve them efficiently, turning data into actionable insights.

## Understanding of smells

### Definition of monitoring smells
Monitoring smells are signs that something isn't quite right with your monitoring setup. They can be subtle and easy to miss, but if ignored, they can grow into bigger problems over time. Just as code smells hint at underlying issues in code quality, monitoring smells point to weaknesses in how you track and respond to system health.

### Why Monitoring Smells Metter?
When the development team begins working on a solution, they typically follow a roadmap with planned timelines and deadlines. However, in prod, the only deadline that truly matters during a critical issue is **right now**. A production outage demands immediate action to minimize costly downtime. For instance, if your SLA guarantees 99.99% uptime, this translates to just 52 minutes of allowable downtime per year or roughly 4 minutes per month

This is where monitoring smells come into play. To act quickly, you need clear, actionable insights. No barriers or delays in your monitoring system. In those precious minutes, you need to dive into logs, identify the issue, and implement a solution without wasting time battling with your monitoring setup. If there's any obstacle—like noisy alerts, missing metrics, or unclear data, you'll end up spending valuable time. In high-stakes situations, **effective monitoring can make the difference between a quick fix and extended outage.**

### Example of monitoring smells 
There are plenty of monitoring smells, but here are some of the most common and impactful ones to watch for.

#### Alert Fatique
One of the most common monitoring smells is alert fatigue. When too many alerts overwhelm teams, causing missed or delayed responses. Constant notifications make it easy for critical alerts to get lost in the noise. For small teams, managing a high volume of alerts can be especially challenging, often resulting in missed alerts or slower reaction times.

Also alert fatigue can create risky habits, like "waiting before acting" because some alerts seem to resolve themselves. For instance, if **` Alert A`** usually clears when **`Alert B`** appears, the team might delay responding to Alert A, assuming it`s not critical and start waiting for Alert B. This can be dangerous if a truly urgent issue goes unnoticed. In some cases, alerts may remain unaddressed for minutes because engineers are already busy with other notifications. This delay highlights how alert fatigue can slow response times and compromise system reliability.

> A notable example is the 2013 Target data breach. Target's security systems detected an intrusion and issued multiple alerts, but due to alert fatigue—where the security team was overwhelmed by a flood of notifications and the critical warnings were ignored.
This oversight allowed hackers to steal credit card details of 40 million customers and personal information of 70 million more. The breach cost Target an estimated $200 million in damages, severely tarnished its reputation, and ultimately led to the resignation of both its CEO and CIO.

This case underscores the dangers of alert fatigue and highlights the critical importance of effective alert management. Streamlining alerts, reducing noise, and prioritizing critical notifications are essential to avoid such costly failures.

#### False positive and false negatives
False positives and false negatives are common challenges in monitoring systems. False positives occur when alerts are triggered unnecessarily, such as minor fluctuations causing performance warnings despite the system functioning normally. These alerts create noise, overwhelm teams, and can lead to alert fatigue, where critical notifications are ignored. On the other hand, false negatives are more dangerous, as they occur when real issues go undetected. For instance, a failing dependency might not trigger an alert due to lenient thresholds, leading to undetected downtime or degraded performance.

To address these issues, monitoring systems need fine-tuned thresholds, smarter alert mechanisms, and regular validation. Tools like anomaly detection and alert correlation can reduce false positives by focusing on real issues, while continuous testing ensures critical problems aren't missed. Striking a balance between accurate alerts and reduced noise improves system reliability and boosts confidence in the monitoring process.

#### Blind spots in monitoring
Blind spots in monitoring are parts of your system that are not being watched. This means problems can happen without anyone noticing until it's too late. These gaps can cause big issues like downtime, poor performance, or security risks. For instance, consider a payment service that relies on a third-party API for processing transactions. If the API experiences intermittent failures and there are no alerts monitoring its **`response times`** or **`error rates`**, the issue might go unnoticed until customers start reporting failed transactions. By then, the damage is done, orders are lost, and user trust is impacted.

Without monitoring this critical dependency, your team is left to investigate the problem manually, often with incomplete information. This results in slower resolution times and frustrated customers or gap on SLA. To avoid such blind spots, it's important to monitor all dependencies, including external services, and set up alerts for unusual behavior like increased latency or failure rates. Comprehensive monitoring ensures potential issues are caught early, minimizing their impact.

> Consider this scenario: a new feature is introduced, relying on a dependency like RabbitMQ. Despite its importance, the monitoring dashboard lacks critical metrics such as the active message count, and no alerts are set up to detect issues with this metric. When you ask why, the response is typically, "We just launched the feature, and monitoring will be added soon."
When you ask about basic metring like memory usage on an instance, the response can be, "***We`ll add it in the next iteration.***" However, this promise rarely materializes.

Unfortunately, "**soon**" often turns into "**never**." This reactive approach to monitoring creates dangerous blind spots, leaving your system exposed to untracked issues that can escalate into major problems. To avoid this, monitoring must be prioritized as an integral part of the development process, rather than an afterthought deferred indefinitely.

#### High Mean time to Resolution (MTTR) due to lack of insight
When an alert is triggered, a high mean time to resolution (MTTR) often signals a lack of actionable insights. This occurs when the monitoring system detects a problem but doesn't provide enough context to identify the root cause. As a result, engineers are forced to sift through logs and metrics without clear guidance, wasting valuable time on investigations and delaying resolutions.

A common excuse is, ***Our system is complex; it takes time to investigate.*** In reality, this often points to an inadequate monitoring setup. A well-designed system should deliver detailed, actionable insights to quickly identify and address issues, rather than leaving teams to rely on unstructured data. If your MTTR remains high, it`s a strong indication that your monitoring tools need to be improved for better visibility and faster diagnoses.

#### Overly Complex or Redundant Rules
This monitoring smell arises when alerting rules are overly complex or redundant, leading to confusion and inconsistency. For example, your system may be set to autoscale, but you still receive an alert instructing someone to scale manually. Even worse, there might be alerts with vague runbooks like, "***Wait an hour, and if it's not resolved, restart the pod.***" Such scenarios raise critical questions: Why wait? What's the SLA impact if action is delayed?

These unclear and inconsistent rules point to a lack of priority and reliability in your monitoring setup. When alerts depend on manual steps, ambiguous instructions, or delays, it indicates insufficient clarity and automation. This creates gaps in response time, undermining the efficiency and effectiveness of your incident management process.

#### Undefined or Arbitrary Thresholds
This is one of my favorites: magic numbers. For example, an alert is set to trigger if the failed request count exceeds 250. Why 250? No one knows. Or, if the average request duration is over 5 minutes, an alert fires. Should we look at percentiles? No. Should we exclude batch processing requests? Nope, just take the whole average.

Then there's the classic: "Scale up if CPU exceeds 75%." Why 75%? Was there a stress test? No. Can your system scale before it is too late? I don't know. It's just the number someone used at their last company, so they assumed it's good here too.

These arbitrary thresholds, without data or reasoning to back them up, create confusion and ineffective monitoring. Thresholds need to be based on real analysis, such as performance tests, business impact, and system behavior, rather than random guesses or inherited practices.


#### One-Size-Fits-All Alerting Approach
The one-size-fits-all approach to alerting is a frequent pitfall in monitoring. For example, a rule to trigger an alert when memory usage exceeds 75% might seem reasonable. However, if your system is designed to optimize performance by using as much memory as possible, this threshold would generate constant alerts, overwhelming teams with unnecessary notifications. This mismatch between general thresholds and the system's design reduces trust in the monitoring system.

Another example involves using average response times across all endpoints. While the overall average might look fine, it could obscure critical issues for specific tenants. For instance, a single-tenant system with a VIP customer might experience slow response times for their dashboard while other endpoints perform normally. A generic alert based on the system-wide average could miss this tenant-specific issue, impacting customer satisfaction and trust.

Instead of using generic thresholds, monitoring systems should be customized to fit the specific needs of your environment. By analyzing historical data and understanding the system's architecture, you can set tailored thresholds for different components. This approach not only reduces noise but also ensures that alerts are actionable, enabling teams to respond effectively and maintain system reliability.

## Strategies to Resolve Monitoring Smells
Building a robust monitoring solution requires thoughtful planning and alignment with product goals and system architecture. Start by asking key questions about the project and company objectives:

**Understand Business Goals**: Discuss with the product team to identify the critical outcomes the monitoring solution needs to support.
**Define SLAs and SLOs**: If there's a legal team, confirm whether Service Level Agreements (SLAs) exist or work with stakeholders to define internal Service Level Objectives (SLOs). Also don't forget that. Without SLO, SLA is not really usefull since there is not enought room for improvement. 
**Make it visible**: Make these goals visible to everyone. For example, If an SLA or SLO exists and there's a budget, consider creating visual reminders like posters or dashboards to keep the team aligned with these targets. Send reminder emails and make sure when there is an update for any of the goal, make it visible for everyone. 

Clear goals and shared understanding provide the foundation for a well-designed monitoring solution that meets both technical and business needs.

### Prioritizing Business-Critical Metrics
Assuming you have well-defined SLAs and SLOs, the next step is to identify which parts of your application are the most critical. Use this information to determine and prioritize business-critical metrics.

For example, if your system involves image processing, metrics like memory usage and CPU utilization are crucial. For an e-commerce website, response time and transaction success rates are key indicators of performance.

Start defining required metrics from important to nonimportant. Focus on these metrics to ensure your monitoring setup aligns with the application's unique requirements and supports your business objectives effectively.

Also create internal dashboards tailored to critical metrics and share them across teams. This ensures transparency and aligns everyone around uptime and performance. **While sales numbers are vital, uptime and performance are what make those sales possible.** A visible focus on monitoring ensures everyone in the company recognizes its impact on overall success.

### Refining Alerting Rules and Thresholds

Once you have identified your metrics and SLOs, start defining alerts based on mission-critical metrics. However, determining whether a 3-second response time is good or bad requires more than assumptions. Here's how to proceed

 Collaborate with different teams to understand what performance benchmarks are reasonable for your system. Use data from performance testing to set realistic thresholds for alerts. If tests show consistent response times under 2 seconds, a 3-second threshold might indicate a problem.

### Setting Meaningful, Data-Driven Thresholds
Make sure you know when to trigger an alert during performance tests. Don't rely on your gut feeling or instincts—use real data from the product team. If you're setting performance thresholds or firing alerts based on monitoring data, these thresholds need to be data-driven, not guesses.

If you don't have proper thresholds defined, raise the flag and inform your company or management. Getting those thresholds is just as important as setting up the alerts themselves. Good data leads to better decisions, and better decisions keep the product running smoothly! 

> **Performance test if Needed:** If valid performance tests don't exist, prioritize creating the necessary infrastructure and processes. **Without reliable testing data, alert thresholds are just guesses.**

Data-driven thresholds ensure your alerts are actionable and relevant, improving your monitoring system's accuracy and effectiveness.

### Using Adaptive Thresholds or Anomaly Detection for Dynamic Metrics
Different operations have different performance expectations. For example, payment processing will naturally take longer than an index page load. If you average performance across the entire website, you're mixing apples and bananas, making the data meaningless. 
If 50 out of 100 requests fail, the failure rate is 50%—a critical issue. But if 50 out of 10,000 requests fail, the failure rate is only 0.05%, which may not require immediate attention. Avoid hardcoded thresholds. Instead, make thresholds dynamic, adapting to the specific context and workload of different operations.

Additionally, leverage anomaly detection tools, such as those available on Azure/AWS. These tools automatically detect unusual patterns, helping to identify potential issues without relying on static rules. Integrating anomaly detection into your monitoring setup can significantly enhance its accuracy and responsiveness. Most importantly, support those anomaly detection alerts with system spesific alerts.

### Automated Alert Grouping and Suppression
Automatically group related alerts to reduce noise and focus on the real issues that need attention. For example, if a dependency fails and triggers 8 separate alerts, that's a sign of poor alert management. Instead of overwhelming the team with multiple notifications, group them into a single topic and tied to the failing dependency.

By grouping alerts, you make it easier for your team to identify root causes and act efficiently and reduce alert fatigue by cutting down unnecessary notifications.

### Correlation of Alerts for Root Cause Detection

Focus on alert correlation to identify root causes rather than just addressing symptoms. For instance, if a dependency fails, proper correlation should help you trace the failure to the specific system or service responsible. This reduces guesswork and speeds up resolution. Root cause identification through correlation ensures your team addresses problems at their source, improving system reliability and reducing repeated incidents.

### Using Distributed Tracing, Centralized Logging, and Dashboards

Integrating observability tools like tracing and logging allows you to pinpoint issues more quickly and accurately. Tracing helps track requests across different services, showing where delays or failures occur in complex workflows. Logging provides detailed records of system events, offering context and insights for troubleshooting. Together, these tools give you a clear picture of what's happening in your system, enabling faster root cause analysis and resolution.

### Post-Incident Reviews for Continuous Improvement
After an incident, evaluate how well the alerts performed. Analyze whether the alerts provided timely and actionable information. Identify any gaps or unnecessary noise. Modify thresholds, rules, or notification settings to make future alerts more precise and effective. 

**Provide an Incident Report**. Document the issue, its impact, root cause, and the steps taken to resolve it. Include recommendations for improving monitoring. Implement mechanisms to detect recurring errors or exceptions. Take proactive, aggressive steps to resolve them and prevent future occurrences. This process ensures continuous improvement in your monitoring system, making it more robust and reliable over time.

### Adjusting Monitoring Rules Based on Evolving System Baselines
As your system evolves, your monitoring setup must adapt too. Regularly review and update alerting rules to ensure they remain relevant. For example: 
- Adjust for Changing Metrics: Page load times, for instance, may vary over time. Update thresholds to reflect the system's current performance.
- Address New Dependencies: Hidden or newly added dependencies can introduce vulnerabilities. Monitor these proactively to catch issues early.
- Collaborate with Development Teams: Work closely with developers to identify changes in the system and adjust monitoring accordingly.
- Use Application Mapping: Compare updated application maps with previous versions to uncover dependencies and potential blind spots.
Always remain vigilant, as even small changes in the system can impact production monitoring.

## Conclusion
### Key Takeaways for Building Effective Monitoring
Monitoring is your safety net for keeping systems reliable and running smoothly. But like any tool, it can get messy if you don't keep it in check. Things like too many alerts, missing data, or poorly set thresholds (we call these monitoring smells) can make it harder to spot and fix problems fast.

To stay ahead, ditch the guesswork and go data-driven. Focus on the metrics that really matter for your users and business. Use tools like anomaly detection, adaptive thresholds, and alert grouping to cut through the noise and make your alerts smarter. And don't forget to work with your team to review and improve your setup regularly. It's all about learning and adapting.

Remember, effective monitoring is not just about detecting problems but enabling quick, informed responses to minimize downtime and ensure a seamless user experience. Through continuous improvement, regular reviews, and clear communication, your monitoring system can evolve into a cornerstone of your organization's reliability strategy.

In the end, monitoring isn't just about tools. It's about creating a culture of observability, accountability, and adaptability. With these principles in place, your team will be equipped to handle challenges with confidence, keeping your production systems robust and your users happy.
