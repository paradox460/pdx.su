---
date: 2025-03-28T12:53:45.465618-06:00
title: Trying, and failing, to build an ESPHome powered irrigation system
---

# Trying, and failing, to build an ESPHome powered irrigation system

![sprinklers running over green grass](/postimages/2025-03-28-trying-and-failing-to-build-an-esphome-powered-irrigation-system/frontyard.jpg)

I've been enthusiastic about [ESPhome][esph] for a while now. It seems to be the perfect medium between turn-key home-automation appliances, and 100% DIY stuff. I've used it to measure the temperature of my chest freezer, to [fix up a cat feeder no longer supported by the manufacturer][catfeeder], and to add an optical rain sensor to my weather station.

So naturally, when reading through the documentation, and coming across the Sprinkler controller, I thought "This would be an excellent project."

## Enter RainMachine

Back in 2020, when we purchased this house, I did a bit of research, and came across two real contenders for the irrigation controller I wanted. RainMachine, and [OpenSprinkler][os]. Both were aimed more at the diy-ish type, but the RainMachine was glossier than the OpenSprinkler, and seemed the better investment. Their software was slicker, and the controller seemed just smart enough to do what I wanted, but not get in the way.

Others, such as Rachio, or the big names like Orbit's B-Hyve, Rainbird's Wi-Fi enabled one, and offerings from K-Rain and Hunter, just didn't appeal to me. All were either dumb controllers with some smarts crudely bolted on, cloud-locked, or some similar combination of negatives.

I wasn't looking for a tremendous amount of intelligence in my sprinkler controller, rather, I wanted a way to just set the schedule from a website or my phone, have it adjust the watering depending on how much summer rain we get, and allow me to start and stop stations remotely, probably from my phone, so I can work on the sprinklers as problems come up. HomeAssistant integration was an added bonus, but ultimately not something I was terribly concerned with at the time.

## Exit RainMachine

The RainMachine has served me well for the last 5 years, but over the last few, the company behind it has seemingly been in rather dire straits, and, as far as I can tell, has gone out of business now.

A few years ago, they transitioned their online "cloud" services to a premium plan. The sprinkler controller still works completely fine without their cloud, but the cloud gives you nice things like no-fuss remote access, more weather providers, and (purportedly) priority support. And the price for it wasn't too bad, so I paid for it for a couple of years. I could have had my own remote access working fine; I've got tailscale running on my home network, but if a few bucks a year kept the company going, I was willing to pay for it.

Sadly, it didn't keep them going. Over time, the connections to the controller became more and more unreliable. Sometimes the app would just sit there, loading infinitely, without connecting. It didn't matter if I was connected to the LAN the controller was on, or was remote, it just wouldn't load. Sometimes even attempting to load the (lan IP) website in a browser wouldn't work, requiring a trip to the controller in the garage to reboot it. And even when it did work, you'd randomly get sluggish behavior, such as _not_ turning on a zone when given a command to do so, or worse, not turning off a zone when instructed to.

Finally, in late summer of 2024 (last year), my grass began to die off in places. At first, I dismissed it as the usual hot-summer browning, confident the grass would turn back to green when the temp fell a bit. But one night, up late, I noticed I didn't hear the sprinkler running. Checked the app. Non-responsive. Checked the website. Non-responsive. Went out to the physical controller. Completely locked up. Had to power cycle it, and then I found out that it hadn't watered in _a week_. It had failed receiving some weather update, and just crashed and not recovered.

I was unable to renew my cloud subscription earlier that summer, and now it appears that the controller wasn't reliable at all.

I could have just taken the device completely offline, firewalled it to not connect to the internet, and pushed weather updates into it from HomeAssistant, but I was already a bit tired of some of its other drawbacks, and so wanted to explore other options.

## Getting started with a DIY controller

![ESPHome-powered irrigation controller](/postimages/2025-03-28-trying-and-failing-to-build-an-esphome-powered-irrigation-system/esp-controller.jpg)

I was very interested in making a sprinkler controller with ESPHome. As I mentioned in the opening paragraph, I've used it for a few tasks around the house, and have been rather impressed. And so it seemed like the perfect fit.

I went online and ordered a [relay board, specifically a KinCony KC868-e16s][kc]. This board has an ESP32, 16 relays, and some IO multiplexers to allow easy control of all the relays and inputs. It seemed like a perfect fit for an irrigation controller; just wire up 24VAC to the relays, connect each station to the other side of the NO contact, and then connect the stations common wire to the other terminal of the transformer. Presto, nice simple irrigation controller.

Software wasn't too much harder to connect up. The [ESPHome Devices][espd] page has a nice sample of what a basic configuration for this board would look like, and so I just started with it, editing the parts I needed. Initial testing was promising; I was able to switch every relay on and off from HomeAssistant, trigger the piezoelectric buzzer, and listen to inputs on the various input pins.

Basic relay clicking working, I set up the [sprinkler] component, and got the various stations set up. I wanted to have two different "controllers", one that would run my high-pressure rotor sprinklers, and one that would run the low pressure drip lines. One of the more disappointing parts of my RainMachine was that it had a singular master controller, so if you wanted to control a pump AND a master valve, it was all or nothing. For the low pressure drip lines, the supply water pressure would be strong enough to give them what they need, and the boost pump was unnecessary. With the rain machine, I had to install pressure regulators at the head of each dripline, just to avoid blowing out the drip plugs.

Depending on how you set up your controllers, you can have as many pumps, master valves, whatever, on any zone, and there's not actually a need to split them up into separate controllers. As the system progresses through a "program", it will turn on and off the various pumps and valves as needed. However, I wanted to have different run cycles for these, as well as running multiple short drip lines at once, to cut down cycle time, and so separate controllers made the most sense for me.

After a bit of YAML, I had what I thought would be a passible configuration. Flashing the device, I opened up HomeAssistant to test, and started a program that would run through each station, 5 seconds per station. Station 1 and 2 fired off just fine, but when it came time for Station 3, the "pump" relay switched off, then the station switched off, while leaving the master valve on, and then the whole thing rebooted.

I fiddled with my configuration a few times, figuring one of the proxy switches I'd made to turn on/off both the pump and master valve from a single switch was the culprit. But even removing it and going down to a single, physical master, I was still having the reboot issues.

Connecting up a serial terminal, so I could actually watch the logs, not whatever the ESPHome sent over the network, I tried to run another cycle, and saw something that made my heart sink. Every time it got to the third station, it had a panic, and rebooted.

I'm not tremendously well versed in embedded software, and so was well out of my depth here. So I collected some logs, opened an [issue] with what I'd found, and essentially consigned the controller to the "future project" parts bin.

I could have removed the sprinkler component, and just used a bunch of switches to control the zones. There are [homeassistant addons][iu] that can automate sprinkler systems that are little more than collections of switches. But the itch at the back of my head was saying "this is becoming a fractal of complexity".

I want my irritation system to be something that I can tinker with when I want to, but will more or less work unless I actively break it. And tying the whole thing to HomeAssistant seems to be introducing an unnecessary point of failure. I like using HomeAssistant to _augment_ systems that already exist, to make them better. Any time I have absolute reliance on it, I feel a little uneasy. It hasn't let me down in _years_, but I started HomeAutomation in the dark ages, when things were extremely fragile, and so I remain wary of those.

## OpenSprinkler

Since my RainMachine was essentially non-viable at this point[^1], and I needed a new controller, I looked to [OpenSprinkler][os]. They offer a few different models, but for my needs the basic, 24VAC one, without latching DC solenoids, was what I needed. Since I've got 14 zones, I also needed to buy one of the expansion boards. The base OpenSprinkler controller only has 8 controllable zones, and they solve this limitation by selling expansion boards; little boxes that just have more zone terminals on them, that connect up to the main controller via a short ribbon cable and use I2C.

[^1]: I could have kept using it, as the failure case appeared to be a one-off. But I still didn't feel comfortable with it after that

OpenSprinkler lets you do _nearly everything_ I've wanted with my irrigation systems. It lets you have 2 "master" controllers, I'm using one for a master valve and one for a pump. Each zone can use one, both, or neither master control. It lets you group your zones into 5 "groups" for exclusivity control; all the zones in one group run sequentially, but you can run zones from different groups in parallel. There are 4 main groups and one special, "parallel" group, in which all zones can run parallel to any other zones, including others in the parallel group.

I was able to quickly get my zones set up, a few basic watering programs set, and so far have yet to encounter any actual limitations that matter to me.

There is a [3rd party homeassistant integration][hacs], which I'm running; it brings a ton of control into HomeAssistant, which is useful for a few of the programs I've used in the past. During the summer, I have a little automation set that runs a few zones for a short period of time, 5 minutes or so, when the outdoor temperature gets above 90º. This gives my chickens a bit of mud to go sit in and cool off, and seems to keep them pretty happy. The HomeAssistant integration allows me to fire off individual zones OR a program, using the Actions system, so I've got some flexibility on how I approach it.

The OpenSprinkler system isn't without its flaws, and some of them are rather notable to me. But none of them are dealbreakers, or even really things that prevent me from doing what I want to do, they just make a few things more complex than I feel they should be.

The UI isn't particularly nice to look at. Its serviceable, and by no means non-functional, but compared to the gloss of something like the RainMachine, it's not as good. That said, it _actually works_ consistently, and fast, which isn't something I can say for the RainMachine. Taking the theme of UI considerations, there's a bit of an inversion when it comes to splitting up a run cycle[^2]. With both the RainMachine and the ESPHome sprinkler component, you would set your _total_ run time for a zone in a program, and then use a _divider_ to choose how many cycles there were. A zone set to run for 30 minutes, with a divider of 2, would run for 15 minutes in each cycle, with the cycles typically being back to back. OpenSprinkler does the inverse of this, they use a _multiplier_ approach. You set the run time of each zone, and then set a cycle count and delay time. Frustratingly enough, the delay time lacks a "resume after the first cycle has completed" feature. This isn't an issue if you have your zones set to the same exclusivity group, their run times will just queue up, but if you make heavy use of parallel groups, and allow for weather influenced changes to cycle times, you could get overlap

[^2]: You can increase water retention in soil by spreading out the amount of water you put on it over a short period of time. Instead of dumping all the water for a zone run in a single pass, you split it up, allowing the ground to rest and absorb some water. This prevents run-off, and generally leads to more efficient use of water.

The weather system for OpenSprinkler is rather powerful, but getting your own weather sources, such as my own personal weather station, into the system isn't terribly convenient. You need to run a weather data provider program on your own server, and use that to push data into the controller. OpenSprinkler provides one that uses several online data sources, and swapping over to your own isn't terribly hard, but compared to the RainMachine, which allows for a simple HTTP push of weather data, which can be triggered by things such as WeeWX _or_ HomeAssistant, it does stick out.

Fortunately, all the weather system is used for is doing weather level adjustments. You can actually set these to completely manual adjustments, and then use something like the [smart-irrigation hacs][smart] package to calculate and push adjustments from HomeAssistant.

But other than those little bits of discomfort, I'm overwhelmingly impressed by OpenSprinkler. Let's hope I stay impressed throughout the year.

And just because I had a bad experience with a particular ESPHome system, doesn't mean I'm swearing off it either. I've got another project coming along soon, and when finished I'll get a blog post about it up.

[esph]:https://esphome.io
[catfeeder]: /blog/2024-01-19-fixing-a-broken-smart-cat-feeder-with-esp32/
[os]: https://opensprinkler.com
[kc]: https://www.kincony.com/kc868-e16s-hardware-design-details.html
[espd]: https://devices.esphome.io/devices/KinCony-KC868-E16S
[iu]: https://github.com/rgc99/irrigation_unlimited
[hacs]: https://github.com/vinteo/hass-opensprinkler
[smart]: https://jeroenterheerdt.github.io/HAsmartirrigation/
[issue]: https://github.com/esphome/issues/issues/6872
[sprinkler]: https://esphome.io/components/sprinkler
