---
title: "How to control Raspberry Pi Fan"
date: "2023-03-22"
author: "Ugur Elveren"
categories: ["Technical"]
tags: ["Raspberry Pi", "fan control", "Python"]
description: "A guide on controlling the fan speed on a Raspberry Pi using Python and GPIO pins based on temperature readings."
---

Last week, I did something unplanned: I bought a Raspberry Pi without any specific project in mind. I came across a Mastodon account (@rpilocator@mastodon.social) that helps people locate Raspberry Pis and I decided to get one. And now, here it is! I'm writing my first blog post about the Raspberry Pi Fan Control.

Along with the Raspberry Pi, I purchased a case, some heatsinks, and a fan. My first blog post is about controlling the fan using your own software. I'll be honest, I didn't plan on developing anything at first but decided to give it a try.

Before we start developing our tiny Python script, we need to install Python and the necessary libraries.

```
sudo apt-get update
sudo apt-get install python3-dev python3-pip
sudo pip3 install RPi.GPIO
```

There is one more thing that we need to do. Which is, setting up wires for the fan. I have three wires that I need to connect. Red, black, and blue. It might be different for different fans but in my case red is for power, black is for ground and blue is for the fan's speed.

I connected GPIO pin 4 for power (red), GPIO pin 6 for ground (black), and the third wire of the fan to GPIO pin 12 (blue) for speed control.

Now, we need to import the libraries that we will be using:

```python
import RPi.GPIO as GPIO
import time
```

In addition, we need to define the GPIO mode and set the output board based on physical pin numbers. Once the output pin is defined, we can initialize PWM on pin 12 with a frequency of 50Hz:

```python
GPIO.setmode(GPIO.BOARD)
GPIO.setup(12, GPIO.OUT)

fan = GPIO.PWM(12, 50)
```

After this step, we need to measure the temperature at certain intervals and adjust the fan speed accordingly. To achieve this, we will create an infinite loop and check the temperature every 5 seconds:

```python
while True:
    temp = int(open('/sys/class/thermal/thermal_zone0/temp').read()) / 1000
    if temp < 38:
        fan.ChangeDutyCycle(0)  # Turn off the fan if temperature is below 38C
    elif temp >= 38 and temp < 40:
        fan.ChangeDutyCycle(30) # Set fan speed to 30% if temperature is between 38C and 40C
    elif temp >= 40 and temp < 43:
        fan.ChangeDutyCycle(50)
    elif temp >= 43 and temp < 45:
        fan.ChangeDutyCycle(80)  
    else:
        fan.ChangeDutyCycle(100) # Set fan speed to 100% if temperature is above 45C
    time.sleep(5) # Wait for 5 seconds before checking temperature again
```

To run the script, simply enter the command `sudo python3 fan.py` in the terminal. This will start the infinite loop and the fan will adjust its speed based on the temperature readings.

If you would like to view the entire script, you can access it from the GitHub Gist that I have created. The link to the Gist is here. Feel free to use the code as a starting point for your own projects, and don't hesitate to reach out if you have any questions or suggestions for improvement.
