---
date: 2025-06-11T18:27:38.842670-06:00
updated: 2025-06-22T11:36:33.0000-06:00
title: How a simple chicken coop door opener became a huge project
amazon: true
---

# How a simple chicken coop door opener became a huge project

![The automatic opener, in all its glory](/postimages/2025-06-11-how-a-simple-chicken-coop-door-opener-became-a-huge-project/PXL_20250428_011031144.MP.jpg)
The door and opener.

I have hens. A decent amount of hens. And one thing you have to do when you have hens is secure them at night. Most people will agree that chicken is tasty, and most predators share that opinion. So a big hen house full of tasty birds is a tempting target for any number of raccoons, foxes, cats, opossums, and more.

When we first got hens, we kept them in a small coop we ordered online. It wasn't particularly well-made, and the doors were flimsy. But it was good enough for our first year of birds, and by year two we knew we needed something better. To build a better coop, I laid a concrete pad, stuck a Costco plastic shed on it, and cut a hole in the side for a door. Our local farm store sold a [simple automatic door](https://www.chickenguard.com/product/pro-door-kit/), which mounted over the hole, had a rudimentary set of programs, and did the job reasonably well. This unit gave us 3 good years of service, and would likely have given more. But there were a few issues that I wanted to address.

## The problems

During the summer, we have a lawn care company come by every month to spray various treatments on the lawn. Things like fertilizer, pesticides, the usual suburban lawn treatments. They usually give me 24 hours notice they'll be heading out to our property, so the night before I can disable the next morning's auto open feature, keeping the hens inside for a reasonable time after whatever substances have been applied to the yard have had a chance to soak in. The door has no remote control features, all interaction has to be done at the control module. Its interface is reminiscent of early 2000s electronics, with lots of holding buttons down, navigating menus on a single line dot matrix display, and lots of frustrating repetition.

During the shoulder seasons, the weather can be unpredictable. Sometimes we get snow as early as September, other times we don't have snow on the ground until January. We like to let the birds out as much as possible, but don't want to wake up and have hens freezing in the snow. So we typically disable auto-open in mid-fall, and re-enable it in mid spring. But if we have a long, warm fall, or a warm, early spring, we have to manually open the door every day to let the birds out, until we decide to switch to automatic opening.

As far as programmable open times, the unit has a few modes, aside from manual opening. The obvious mode is time based, which uses a little RTC on the device to keep time, and opens or closes at preset times. Works well enough, even with clock drift. Chickens aren't particularly picky about time. The other mode is sensor based, which uses an internal light sensor to determine the sun rise and set times. We primarily used this one, as the rise/set time changes over the course of the summer, and having it set at something like 9 PM might be too late for the edges of the season, but too early for the middle. But since it's a light sensor, it depends on the ambient lighting. Stormy days, or even just heavily overcast days, would trigger the sensor early. The hens seem to know the difference between a cloudy sky and sunset, and so we'd sometimes find hens waiting patiently outside a locked door.

## Things the existing door did well

Looking at how the existing automatic door opener worked, there are a few very clever choices that were made, that I wanted to keep. The controller and motor don't directly drive the door, rather they use a short length of cable to raise/lower the door. The door itself has a latching mechanism that engages when it hits the end of its downwards travel, and disengages when the cable begins to lift. So all the motor has to drive is a winch. An additional benefit of this is that there is minimal chance of hurting a chicken if she blocks the door. The door itself is rather light, a couple pounds at most, and so if the full weight of it lands on a bird she can shrug it off.

I've seen some other door opener designs that use direct-drive motors (like a garage door) or linear actuators, and then have to have added complexity in detecting door blockages and handling them.

## This should be simple, right?

So, keeping what the existing system did both right and wrong in mind, the solution, to someone who has recently been a bit obsessed with Home Automation, particularly with [ESPHome](https://esphome.io/), was obvious. Build a new door opener, one that could be controlled via Home Assistant. Building atop this platform gives me full remote control, from a system I already use, as well as some robust scheduling primitives, like sunrise/sunset times, ambient temperature, and anything else you can think of.

To enable such an opener, I'd need a few things:

+ **A control module:** Some ESP32 variant. It would need to have an external Wi-Fi antenna, since this will sit out in my yard, and I wasn't sure about how strong my Wi-Fi signal would be that far. [Seeed Studios Xiao ESP32C3](https://amzn.to/3HAfNEd) fit the bill nicely.
+ **A Motor:** I probably overestimated the specs on the motor, but I wanted something that would turn reasonably fast, have a fair bit of torque, and use a gearbox to get as much power as possible. Amazon is covered in motor modules for DIYers, and so I picked [this one](https://amzn.to/4mXIYBn), based on little more than the fact that it was 12V, 100RPM, and small-ish.
+ **A way of controlling the motor:** I know you can't drive that sort of motor directly from a microcontroller, and so I needed a way to control it. A simple on-off relay wouldn't work here either, as I needed to be able to reverse the polarity to drive the motor both clockwise and counter-clockwise. A [h-bridge](https://amzn.to/3SNvHxl) fits the bill perfectly, and this particular unit also outputs 5V, for powering a microcontroller
+ [**Wi-Fi Antenna:**](https://amzn.to/4jObC50) for obvious reasons
+ [**A weatherproof button:**](https://amzn.to/4lncfUD), to control the door manually
+ **A power supply:** More on this one later, but I had to revisit this point a couple of times.
+ **An Enclosure:** I have a 3D printer. I have lots of filament. This was probably the easiest part.
+ **A spool for the cable:** Again, 3D printer

![ESP32, H-Bridge, and a Motor](/postimages/2025-06-11-how-a-simple-chicken-coop-door-opener-became-a-huge-project/PXL_20250305_034604251.jpg)
Components!

## The enclosure

![Cross-section of the enclosure](</postimages/2025-06-11-how-a-simple-chicken-coop-door-opener-became-a-huge-project/CleanShot 2025-06-11 at 19.10.31@2x.png>)

The enclosure started off as a big box, and ended up as a big box. There's not that much you can do different in this space. But there are some subtleties.

The spool sits in its own little mini-enclosure in the box, with a hole for the cable to pass-through. While this won’t prevent everything from getting in, it does separate the electronics from the outside.

For all the external connections the unit will need, I created a pass-through for a [Deutsch Connector](https://amzn.to/4mP8J6K). I have a bunch of these on hand from other projects, and they're a personal favorite. Deutsch sells a bulkhead connector, but I didn't have any, so I made my own bulkhead, which can be anchored into the main enclosure using some M2.5 screws and a few heat-set inserts. For weatherproofing, a TPU gasket is used, that sits between the bulkhead and the enclosure. The antenna and the button both have pass-through holes in the side. The button has its own rubber gasket, while the antenna just uses an o-ring. I also added a little "roof" over each, to slightly increase the weatherization. Probably not necessary, but it looks nice. Finally, the top of the enclosure has a shadow line where it meets the top piece, with a gasket, to further aid in gasket. And then the top itself is held down by 4 M3 screws, engaging with heat-set inserts in the main enclosure.

Since I wasn't entirely sure about how well the 3D printed parts would fit the Deutsch connectors, I made that bulkhead its own part. While my initial print fit the 2-position connector I was initially using, having the bulkhead be a separate part proved to be unusually prescient.

## Putting it all together

Getting everything put together on a breadboard was rather easy, and after a quick flashing of the ESP32 with ESPHome, a bit of yaml, and some inhalation of solder fumes, I had a primitive prototype. I'd click the door open button in HomeAssistant, the motor would turn on, spin for a bit, then turn off. Attaching a spool and string let it actually wind and unwind the string, and putting a 5lbs weight on the end let me estimate how much current it might draw in the wild. Everything was working far too well.

The initial ESPHome component I used was a [Template Cover](https://esphome.io/components/cover/template). The motor controller is tied to a couple GPIO pins, and so this template simply turns the appropriate pins on and off, with some `delay` actions to turn the respective pin off after a time delay. This is pretty much exactly how the existing door opener worked, but while mulling things over, I realized that I'd prefer to have some form of feedback from the door, so I can tell if it was open or closed. Adding this feedback to the system lets you use the aptly named [Feedback Cover](https://esphome.io/components/cover/feedback), which handles most of the automation I had written by hand in the template sensor, as well as letting you do things like open the door an arbitrary percentage. The feedback cover is still mostly time based, but lets you put some end stops in, that will stop the motor when it reaches the end of its travel, regardless of how long it took (within limits, I always left some upper level time limit on there to prevent suck doors from breaking things).

But adding endstops means I needed to add more components. I decided to use [magnetic contact sensors](https://amzn.to/3HDul5T), like you'd use for a door or window in a burglar alarm system. I could stick the magnet on the door, and stick the sensors on the rail it travels along, and get a good indication of when the door is open or closed. These sensors are simple, when a magnet is near, they complete a circuit. Wiring them up to everything is rather simple. One side connects to a GPIO pin, the other connects to ground, and then with a bit of ESPHome yaml, you now have a sensor. I wanted all the connections to be inside the weatherproof box, and so I needed a way to bring in 4 more wires. The 2-position Deutsch connector I was using wouldn't cut it. So I grabbed a 6 position connector, printed a new bulkhead plate, crimped some connectors on the end of the sensor lines, and wired their corresponding positions to the board, and now had feedback. The motor would spin until the endstop for the direction of travel closed, and then it would stop.

Everything worked, so I moved all the connections from a breadboard connection to a hard-solder connection, put everything in the enclosure, sealed it up, and then waited for the weather to warm up, so I could install it on the hen house.

## Getting power to it

![The empty trench](/postimages/2025-06-11-how-a-simple-chicken-coop-door-opener-became-a-huge-project/PXL_20250422_205017567.jpg)
The trench, sitting empty.

I'd decided early on that this opener would run off mains power. I didn't want to have to deal with batteries, deep sleep, or anything else. I needed to get power out to the hen house, the old extension-cord across the yard wasn't going to cut it, for running a water heater in the winter, and a fan in the summer, and so this served as a good excuse. I have an exterior outlet with a junction box on the side of my house, and so getting power from the house across the yard to the henhouse was a fairly simple problem, with a simple solution: Dig a ditch, run some conduit in the bottom, and pull power.

Simple is only a conceptual word here, as the actual project proved a bit more involved. I rented a trenching machine to dig a 3' deep trench from the house to the coop, and in typical trenching machine fashion, the clutch was busted. Judicious use of a spring clamp and a piece of rebar managed to keep the clutch engaged, and within an hour I had a nice deep trench across my yard. And, of course, I hit some sprinkler lines. 3 of them to be exact. Fortunately, I didn't hit the sprinkler control wires, just a main water line and two zone lines. I keep the system depressurized when it's not in use, and so fixing the breaks wasn't complex, but it was a dirty project that took the better part of an afternoon. Once the sprinkler line was fixed, laying the flexible conduit was trivial, and filling in the trench wasn't much harder.

![The filled in trench](/postimages/2025-06-11-how-a-simple-chicken-coop-door-opener-became-a-huge-project/PXL_20250427_000731822.jpg)
Filled in, but still ugly. Grass will eventually move in.

Pulling 3 conductors through the conduit was the usual pain, fish tape and pulling lubricant made it a bit easier, but I'm never a fan of pulling wire through conduit. Beats pulling it through walls, but not by much. I also ran a line of CAT-8, unterminated, if I ever want to add a Wi-Fi extender, cameras, or anything else out at the coop. At the coop side, I put in a large box, put a few outlets inside it, and then I put a small box with an in-use cover on the outside, so powering heaters and fans is a matter of plug and play. Connecting up the wires at the house side, everything read green.

## Mounting the opener, and power troubles

Mounting the opener was easy enough, I just unscrewed the old one, screwed the new one in, tied the cable to the door, ran the power lines from the large electrical box, where a wall-wart transformer turned the 120VAC to 12VDC, and voilà, a working chicken door opener.

Or so I thought. The door closed just fine the first night, and opened just fine the next morning. But the next evening, the door sat firmly open past sunset. Checking the device in HomeAssistant, it showed several log entries of the device rebooting. At first, I worried it might be an issue with an electrical short, so I manually closed the door, and checked the wiring the next day. Everything was fine, and so I enabled some debug logging, specifically setting up a text sensor to tell me the previous reboot reason, and just left the unit to do its thing. The door opened and closed just fine for a few days, and then failed to open one morning. Checking the logs, I saw the same rebooting issue, and this time the debug sensor told me the unit rebooted due to brownout.

The cheap wall wart power supply I used, which claimed to deliver 30W of power was capping out at 15.6W of power, meaning it was seeing voltage drop whenever the motor tried to move. Frustrated, I grabbed a spare [50W Meanwell power supply](https://amzn.to/4jMLwPY) I had left over from some [xmas light projects](https://pdx.su/blog/2024-08-10-diy-permanent-xmas-lights/), wired it up, and put everything back together. Since then the door hasn't given me any troubles.

## The Code

I've more or less glossed over the code up to this point, as its only marginally interesting. The full version is [on my github](https://github.com/paradox460/HomeAssistantConfig/blob/main/esphome/chicken-coop-be4e8c.yaml), which should always be updated, but here are some highlights I thought could be useful to others.

The primary motivational factor of this whole project was being able to turn off auto open at any time. This is handled through a simple template switch, which shows up in HomeAssistant:

```yaml
switch:
  - platform: template
    id: auto_open
    name: "Automatic Open"
    optimistic: true
    restore_mode: RESTORE_DEFAULT_OFF
```

This switch's value is checked during the auto-open automation on the `sun` component, which also handles a delay. Since the hens don't always go to bed exactly at astronomical sunset (when the sun is just below the horizon), I wanted to add a bit of delay to the door closing, so that the birds get in there. Initially, I hardcoded this delay, but after a few tweaks, I got tired of having to recompile and reflash every time I needed to tune it. So I added a few number inputs, which let me set the delay in HomeAssistant, and then have the ESPHome use them for delays when sun events happen:

```yaml
number:
  - platform: template
    name: "Open Delay"
    id: open_delay
    min_value: 0
    max_value: 600
    unit_of_measurement: "min"
    mode: box
    step: 1
    optimistic: true
    restore_value: true
    initial_value: 30
    icon: mdi:weather-sunset-up
  - platform: template
    name: "Close Delay"
    id: close_delay
    min_value: 0
    max_value: 600
    unit_of_measurement: "min"
    mode: box
    step: 1
    optimistic: true
    restore_value: true
    initial_value: 15
    icon: mdi:weather-sunset-down
```

Finally, the `sun` component is where the actual automation happens. The `on_sunset` event is fairly simple, and fires unconditionally. If the door is _ever_ open, I want it closed at sunset (accounting for the delay, of course). The `on_sunrise` event has a logic check to see if automatic open is on, and if so, it waits for the delay from the number component, then closes

```yaml
sun:
  latitude: !secret latitude
  longitude: !secret longitude
  on_sunrise:
      - then:
        - if:
            condition:
              lambda: "return id(auto_open).state;"
            then:
              - delay: !lambda 'return id(open_delay).state * 60000;'
              - cover.open: chicken_coop_door
  on_sunset:
    - then:
        - delay: !lambda 'return id(close_delay).state * 60000;'
        - cover.close: chicken_coop_door
```

For diagnostic information, and because it's fun to see, I also added a couple text sensors that return the next open/close time. These are a wee bit more complex, as they have to translate the text timestamps the `sun` text_sensor component returns into epoch time, do some time math, and then convert them back to timestamps, but it's still fairly basic:

```yaml
text_sensor:
  - platform: sun
    name: Next Auto Open
    type: sunrise
    format: "%Y-%m-%d %H:%M:%S"
    entity_category: "diagnostic"
    update_interval: 10min
    filters:
      lambda: |-
        const std::string input_time(x);

        ESPTime parsed_time;
        ESPTime::strptime(input_time, parsed_time);

        parsed_time.recalc_timestamp_local();
        parsed_time = ESPTime::from_epoch_local(parsed_time.timestamp + id(open_delay).state * 60);

        char buffer[64];
        parsed_time.strftime(buffer, sizeof(buffer), "%Y-%m-%d %H:%M:%S");
        return std::string(buffer);

  - platform: sun
    name: Next Auto Close
    type: sunset
    format: "%Y-%m-%d %H:%M:%S"
    entity_category: "diagnostic"
    update_interval: 10min
    filters:
      lambda: |-
        const std::string input_time(x);

        ESPTime parsed_time;
        ESPTime::strptime(input_time, parsed_time);

        parsed_time.recalc_timestamp_local();
        parsed_time = ESPTime::from_epoch_local(parsed_time.timestamp + id(close_delay).state * 60);

        char buffer[64];
        parsed_time.strftime(buffer, sizeof(buffer), "%Y-%m-%d %H:%M:%S");
        return std::string(buffer);
```

Finally, the interface for controlling this is just a simple card on my dashboard, making use of a pop-up for the more involved settings. You can open, close, toggle auto-open, and view all the information in one place. And its already proven its worth. As I was writing this article up, I got a message from the lawn-care company stating they'll be out tomorrow to spray, and so I turned off the auto-open, which will keep the door shut tomorrow until I remotely trigger the opening.

****![The main dashboard controls](</postimages/2025-06-11-how-a-simple-chicken-coop-door-opener-became-a-huge-project/CleanShot 2025-06-11 at 20.02.31@2x.png>)
Controls on my main dashboard. A toggle for auto-open, then Open, Stop, and Close controls


![The detailed pop up](</postimages/2025-06-11-how-a-simple-chicken-coop-door-opener-became-a-huge-project/CleanShot 2025-06-11 at 20.02.37@2x.png>)
Clicking the icon on the main controls pops up this dialog, giving you a bit more information.

I've thought about adding some more "smarts" on the HomeAssistant side, like disabling auto-open if the temperature is too low, or if its raining, but those are projects for another day.

![The chickens](/postimages/2025-06-11-how-a-simple-chicken-coop-door-opener-became-a-huge-project/PXL_20230901_164421732.jpg)
The chickens themselves.

## Updates

### 2025-06-22

I was having a few issues with brown-outs, even after upgrading the power supply (as mentioned earlier). They were fewer and further between, but for an appliance like this, we don't want _any_ issues. It had yet to leave the door _open_ at night, but there were a few mornings when I'd look outside and not see any hens running about. From what I can gather online, the H-Bridges I use, the ones with the built-in 12V-5V converter, occasionally have issues where the converter will output less than 5V intermittently. It seems to be hit or miss if you get one that has this problem, so I'll continue to recommend them, but if you do get one that has these issues, then you can get a [simple little buck converter](https://amzn.to/4kSS5BK), wire it in series with the H-Bridge unit, and connect your ESP32 to the output of the buck converter instead.

I've been running this setup for a few days now, some of the hottest we've had this year, and it's yet to give me any trouble.
