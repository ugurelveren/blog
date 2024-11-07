---
title: "Automating Script Execution with Systemd on Linux"
date: "2023-03-23"
categories: ["Technical","Linux"]
author: "Ugur Elveren"
tags: ["Systemd", "Linux", "background services"]
description: "Learn how to automate script execution using Systemd on Linux, with practical examples on running background services."
---

In my previous blog post, I created a script that controls the fan speed on my Raspberry Pi. However, I encountered a problem – every time I restarted my Raspberry Pi, I had to manually run the script again, which was not ideal.

In this blog post, I will demonstrate how to automate the execution of any script using Systemd. Systemd is a system and service manager for Linux operating systems.

There are several methods to run software as a background service in Linux, such as using crontab or .bashrc, among others. If you're interested in those methods, you can easily find more information online.

Before we get started, let's make sure that Systemd is installed on your Linux system. You can check the version of Systemd by running the following command:

```bash
systemd --version
```

After verifying that, we need to create a Systemd service file to manage the script's execution as a background service.

To create the service file, open a text editor as root with the following command:

```bash
sudo nano /etc/systemd/system/fan.service
```

If you don't have nano installed, you can use vim or any other text editor you prefer.

Next, copy the following configuration file into the editor:

```bash
[Unit]
Description=Fan Service
After=multi-user.target

[Service]
Type=simple
Restart=always
ExecStart=/usr/bin/python3 /home/<username>/fan.py

[Install]
WantedBy=multi-user.target
```

This configuration file has three sections: Unit, Service, and Install. In the Unit section, provide a description of the service. In this case, we use Fan Service as the description. The `After` line specifies that the service should only be started after the system has finished booting into the multi-user mode.

In the Service section, set the type to `simple` to indicate that the service consists of a single, long-running process that does not fork any child processes. The `Restart` line specifies that the service should be restarted automatically if it exits for any reason. The `ExecStart` line specifies the command that Systemd should execute to start the service. In this case, it is set to run the Python script located at `/home/<username>/fan.py` using the `/usr/bin/python3` interpreter.

In the Install section, set the `WantedBy` line to `multi-user.target` to indicate that the service should be enabled at boot time and started when the system reaches the multi-user mode.

Save the file and exit the editor. Finally, run the following command to reload the Systemd configuration and start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl start fan.service
```

The service is now running in the background and will be automatically started at boot time. Also you can check the service status with the following command:

```bash
sudo systemctl status fan.service
```

Systemd is a powerful tool for managing background services on Linux systems, and it can be used to run any kind of script or software as a background service.

If you want to learn more about Systemd, DigitalOcean has a great article that provides a comprehensive overview of the tool and its features. The article covers topics such as the Systemd architecture, how to create and manage Systemd units, and how to use Systemd to manage system services and processes.
