## Identifying and Resolving Monitoring 'Smells' for Reliable Production Systems

Maintaining the health and reliability of production systems is a constant challenge for any organization. Are your production services running as expected? Are background processes working efficiently? During high-traffic periods, can your system handle the load without bottlenecks or failures? And what about external dependencies—are cloud services stable, or are there issues with third-party APIs? These are everyday challenges for DevOps and SRE teams alike.

Just like code can develop "smells" that hint at deeper issues, monitoring systems can also exhibit "monitoring smells" when something isn't right. By closely observing the SRE team's workflows and outcomes, patterns of problematic monitoring setups often emerge. While I won't be diving into how to build the perfect monitoring system, I'll be sharing practical insights into identifying "smelly" monitoring practices and, more importantly, how to tackle them effectively.

### what is observability and monitoring

When it comes to production performance, two terms often come up: monitoring and observability. Though they're closely related, each plays a unique role in how we understand and maintain system health.

#### Monitoring

Monitoring involves tracking data points that indicate system health, such as CPU usage, response times, error rates, queue backlogs, and configured alerts. These metrics allow us to keep a close eye on the system, spotting irregularities and detecting issues in real time. For example, if response times spike unexpectedly or CPU usage reaches critical levels, monitoring alerts us, prompting immediate action. By focusing on these core metrics, we're able to maintain stability, minimize downtime, and respond quickly when issues arise. Monitoring acts as an early warning system, enabling proactive management to keep our solutions reliable.

#### Observability
Observability takes monitoring a step further, providing deeper insights into system health through logs, traces, and metrics. When we begin questioning the state of a system—such as why a particular service is slow or why errors are spiking—observability tools offer the data needed to answer those questions. Logs capture detailed records of events, traces follow requests as they travel through the system, and metrics provide quantitative measurements. Together, these elements create a comprehensive picture of what's happening internally.

If any question about the system's health can't be answered directly, these observability tools guide the investigation, giving engineers clues and patterns that lead to root causes. Observability, in essence, equips engineers not just to detect problems but to diagnose and resolve them efficiently, turning data into actionable insights.

### Why Monitoring Smells Metter
When the development team starts working on a solution, there's usually a roadmap with planned timelines and deadlines. But in production, if a critical issue hits, there's only one real deadline: right now. An application down in production means immediate action to avoid costly downtime. For example, if you promise 99.99% uptime, you're allowed only 52 minutes of downtime per year or just about 4 minutes per month.

This is where monitoring smells come into play. To act quickly, you need clear, actionable insights—no barriers or delays in your monitoring system. In those precious minutes, you need to dive into logs, identify the issue, and implement a solution without wasting time battling with your monitoring setup. If there's any obstacle—like noisy alerts, missing metrics, or unclear data—you'll end up spending valuable time overcoming those hurdles. In high-stakes situations, effective monitoring can make the difference between a quick fix and prolonged downtime, so your monitoring setup needs to be fast, accurate, and dependable.

## Understanding of smells.

### Definition of monitoring smells.
Monitoring smells are indicators that something isn't quite right with your monitoring setup. They're often subtle and easy to overlook, but if left unaddressed, these small issues can escalate into significant problems over time. Just as code smells hint at underlying issues in code quality, monitoring smells signal potential flaws in the way you track and respond to system health. Recognizing and addressing these smells early can prevent future headaches, helping you maintain a more reliable and responsive monitoring environment.

### Example of monitoring smells 
There are several examples of monitoring smells, but let's dive into a few key ones.

#### Alert Fatique
One of the most common monitoring smells is alert fatigue—too many alerts, which can overwhelm teams and lead to missed or delayed responses. When a team is bombarded with constant notifications, it's easy to overlook a critical alert among the noise. Small teams, in particular, may struggle to keep up with alert volume, potentially missing alerts altogether or delaying responses.

In larger teams with a front-line response, alert fatigue can even lead to informal practices like "waiting 5 minutes before acting" because certain alerts tend to follow a specific pattern. For example, if Alert A usually resolves when Alert B appears five minutes later, the team might delay responding to Alert A, assuming it'll clear on its own. But this habit can lead to severe consequences if something truly critical goes unnoticed. In some cases, alerts can sit unattended for 15 minutes or more simply because engineers are preoccupied with other alerts, illustrating how alert fatigue can impair response times and reliability.

#### False positive and false negatives

Any minor fluctiaction trigger an alert and you never know the alert is a real alert or some kind of false positive. You can hear some conversation like, I am investigating the alert or there is a alert but there is no exception on the system. Also some worst case there are some false negative alerts. There are some possible conversation like this. There was an alert but there is no exception so we ignore the alert and there is a *But* but one of the dependency was failing so we missed that one and we have 96 minutes downtime. so call the legal departmant that we have some problems. 

#### Blind spots in monitoring
Another monitoring smell is the presence of blind spots—areas of your system that aren't being monitored effectively. For instance, imagine a senior developer requests production access to restart an instance due to a corrupted cache. It's a quiet day with low traffic, so he restarts it to fix the issue. But here's the real question: how long had the cache been corrupted? How many users were affected? What was the SLA impact? Instead of an alert or observability tools flagging the issue, a developer had to dig into logs to uncover the problem. This indicates a significant monitoring gap. If your cache or application level lacks monitoring, you're missing critical insights, and the manual discovery means your monitoring setup isn't keeping pace with system health.

#### High Mean time to Resolution (MTTR) due to lack of insight
When an alert does come through, a high mean time to resolution (MTTR) can reveal a lack of actionable insights. In other words, the system senses a problem but can't identify what's wrong. Engineers then have to dig through logs and metrics without clear guidance, leading to time-consuming investigations. The common excuse is often, "Our system is complex; it takes time to investigate." The reality? Your monitoring is inadequate. A well-monitored system should provide enough detail to quickly identify root causes rather than forcing engineers to navigate through unstructured data. If MTTR is high, your monitoring needs to provide better visibility and context for faster diagnoses.

#### Overly Complex or Redundant Rules
This monitoring smell appears when rules are excessively complex or redundant, making alerting inconsistent or confusing. For example, your system might be designed to autoscale, but there's still an alert telling someone to scale manually. Or, worse yet, an alert comes with instructions to "wait an hour, and if it hasn't resolved, call the development team." This raises questions: why wait an hour? What's the impact on SLA if it isn't resolved sooner? Such rules indicate unclear priorities and make monitoring unreliable. If alerts need manual steps, delays, or special instructions, it's a sign your monitoring setup lacks clarity and automation, creating unnecessary gaps in response time.

### Common Monitoring problems
Since we talked about some smelly monitoring practices, we can start talking about common monitoring problems and start discussing about what are we going to do.

#### Too Many Alerts and Insufficient Context
This is one of the common and we already talked about it is a smelly practice. Too many alerts. You can hear from the development team that they can mentioned they have 600 alerts to monitor the production. So what. Why that number is important. When there is a dependency problem i just want to see depenendeyc alert, not 5 different alert which is fired by only a single dependency. Or when there is an alert, i need to know what caused that alert to make sure I can act on it. There is an alert called app is unhealty alert but we don't know the reason. I just want to repead myself again, alert should be a spesific for the problem and with an alert you need to provide some sufficent data to make sure the engineer understand what is the problem. 

#### Undefined or Arbitrary Thresholds
This is my favorite. Magic numbers. If failed request count is more than 250, raise a performance alert. Why 250. No one knows it. Or if the average request duration is more than 5 minutes, then raise an alert. Should i look for the percantile. no. Should I exclude bach processing requests. No take whole average. Or we need to scale up after cpu exceet 75%. Why 75. did you do any stress test. no i used this number on my last company. so 75 is good. 

#### Missing Key Metrics and Blind Spots
When you need to take a look at the memory usage of the instance, you will get an answer for we will add it on it next iteration. Also i can give the scenario. There is a new feature which is using the a new dependency like rabbitmq and your monitoring dashboard does not have age of the queue item and no alert for that. When you ask why 
you don't have this, you will get an answer for we just developed a feature and we will do some monitoring improvements soon. They never do that. 

#### One-Size-Fits-All Alerting Approach
It is also really common and really confusing as well. So there are some general rules and indistry habbits for some stuff. But each system is unique. For example increasing disk when cpu average hits more than 80% having a basic warning is good but if the scaling time of the solutions is taking longer that number might be a problem. 
Or increasing disk size 20% is usually safe however if you have 10tb of disk it means 2tb. and 2tb can be a lot. but there is no answer for all solutions.

#### Noise vs. Signal: Misleading Variations Masking Real Issues
This is also really common. Alert Fatigue and noise on monitoring can lead to devastation. I just want to give an exmaple In 2013, Target's security systems detected an intrusion and issued multiple alerts, but the warnings were ignored due to alert fatigue—security teams were overwhelmed by a constant stream of notifications. Desensitized by the volume, they missed the critical alerts. Hackers exploited this oversight, stealing credit card details of 40 million customers and personal info of 70 million more. The breach led to about $200 million in losses and damaged Target's reputation, resulting in the resignation of its CEO and CIO. This case highlights the dangers of alert fatigue and the need for effective alert management.
### Strategies to Resolve Monitoring Smells

#### Prioritizing Business-Critical Metrics
Focus first on metrics that directly impact user experience or business goals. These are the ones that deserve priority in alerting.
##### Identifying Metrics Linked to User Experience and Business Goals
Define the metrics that matter most for your customers and business – these should be the focus.
###### Refining Alerting Rules and Thresholds
##### Setting Meaningful, Data-Driven Thresholds
Use real data to set thresholds that make sense. Avoid guesswork, and adjust thresholds as your system grows or changes.
###### Using Adaptive Thresholds or Anomaly Detection for Dynamic Metrics
For metrics with natural fluctuation, try adaptive thresholds or anomaly detection to avoid alert noise.
##### Implementing Intelligent Alert Management
###### Automated Alert Grouping and Suppression
Group related alerts automatically to reduce noise and focus on issues that need attention.
###### Correlation of Alerts for Root Cause Detection
Look at how alerts relate to find root causes instead of just fixing symptoms.
##### Integrating Observability for Deep Insights
###### Using Distributed Tracing, Centralized Logging, and Dashboards
Adding observability tools like tracing and logging helps you get to the heart of issues faster.
##### Regular Review and Feedback Loop
###### Post-Incident Reviews for Continuous Improvement
After an incident, review how well the alerts worked. Adjust as needed to make future alerts more effective.
###### Adjusting Monitoring Rules Based on Evolving System Baselines
As your system changes, so should your monitoring. Regularly update rules to keep them relevant.


### Practical Examples of Monitoring Smells and Fixes
#### Case Study 1: Reducing Alert Fatigue in a Microservices Environment
#### Case Study 2: Addressing Missing Metrics in Critical User Flows
#### Case Study 3: Refining Thresholds to Reduce False Positives

### Conclusion
#### Key Takeaways for Building Effective Monitoring
Good monitoring isn’t just about more alerts; it’s about actionable insights that help you catch and fix issues fast.
#### Balancing Monitoring and Observability for Reliable Production Systems
By combining monitoring and observability practices, you get a clearer picture of what’s going on, improving system reliability and reducing stress on your teams.
#### Encouraging Proactive and Adaptable Monitoring Practices
A regular review of monitoring practices keeps things fresh and relevant, helping your system stay aligned with evolving business goals.
