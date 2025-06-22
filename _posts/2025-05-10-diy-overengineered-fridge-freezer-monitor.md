---
date: 2025-05-10T10:39:06.282963-06:00
title: DIY overengineered fridge/freezer monitor
permalink: /blog/2025-05-10-diy-overengineered-fridge/freezer-monitor
amazon: true
---

# DIY overengineered fridge/freezer monitor

I've got a chest freezer that I like to keep an eye on. It's never failed me, but it has several thousand dollars worth of foods and meats in it, and sits out of the way, so it's not something you check every day. If it did fail, it could be catastrophic. Since I have Home Automation, this was entirely unacceptable. So I set out to monitor it.

![Fridge/freezer monitor setup](/postimages/2025-05-10-diy-overengineered-fridge-freezer-monitor/PXL_20240416_190841246.jpg)

## State of the market, 2024

At the time of this project, there were a variety of fridge/freezer products on the market, some of which even had remote monitoring, which was a requirement for this project. But, of the ones I'd found, there weren't any that were HomeAssistant or "DIY-er" friendly.

Both ThermoWorks and FireBoard offer fridge/freezer monitoring tech, and I like products from both companies. But their monitoring tech, at the time, was unsuitable. Both companies products required internet connections; there was no LAN capability, and both, being commercial oriented, were not meant for 24/7 monitoring[^1]

[^1]: Fireboard _does_ offer a 24/7 recording service, but its paid.

Looking outside them for a while, a common approach many people seemed to take was to shove a simple Zigbee temperature probe, the kind you'd leave outside, in their fridge. This, of course, barely works in a small apartment, and in my big ol' house, wouldn't work at all. The signal attenuation through the walls of a big chest freezer alone means you have to put a repeater practically on the other side of the walls, and the cold environment isn't kind to cheap batteries. I probably could have made it work, but it seemed unreasonably complex.

## When they won't build it, you have to

Dissatisfied with what I saw on the market, I went about building my own. I laid down some requirements first:

+ Must be local only
+ Must tie into HomeAssistant
+ Must have replaceable and removable remote probes, ideally K-Type thermocouples.

With these in mind, the obvious candidate was to use an ESP32 device with [ESPHome]. At the time, the only ESPHome project I'd done was the [cat feeder](https://pdx.su/blog/2024-01-19-fixing-a-broken-smart-cat-feeder-with-esp32/), which was mostly just a bit of GPIO and some timing. This would be more complicated.

The ESPHome platform supports use of external modules to translate the weak signals from a K-Type thermocouple to something the ESP32 can use (i.e. a temperature). The module I wound up using was the MAX31855-based module, specifically [this](https://www.adafruit.com/product/269) unit off Adafruit. [ESPHome supports this natively](https://esphome.io/components/sensor/max31855), and so it was a shoo-in.

Wanting to _also_ monitor the conditions of my Garage, I grabbed a [AM2301B ATH based Temp/Humidity sensor](https://www.adafruit.com/product/5181). These are supported in ESPHome via the [AHT10](https://esphome.io/components/sensor/aht10) module.

![The thermoworks food simulant probe](/postimages/2025-05-10-diy-overengineered-fridge-freezer-monitor/PXL_20240416_190826636.jpg)

Finally, I needed the probe itself. ThermoWorks sells a probe called a [food simulant probe](https://www.thermoworks.com/ths-113-350/), which is exactly what it sounds like. It's a square block of plastic, with a probe embedded in the middle. You stick it in your fridge/freezer, and instead of just getting the point reading of metal probe, you get a "diffuse" reading, what a piece of food in the freezer would actually measure as a temp.

Other odds and ends, of minimal importance to the project, were the power supply, which was just a cheap multi-voltage one I picked up at radioshack, [the enclosure](https://www.adafruit.com/product/3931), and a [K-Type extension cord](https://amzn.to/3RXuEKQ), which was used as the "terminal" for the connection to the PCB

## Assembly and testing

Assembly was extremely straightforwards, basically electronics lego. Just solder some headers on a protoboard, solder some headers on the MAX31855 and ESP32 (mine came without them), solder leads from the power cord to the VCC and GND of the protoboard, and then solder the leads from the AHT20 to the protoboard. The K-Type extension cord got its male end terminal removed, exposing the bare wires, which happily set into the screw terminals on the MAX31855.

Once it's all assembled, take your ESP32 over to your computer, flash it with the loader, pair it with HomeAssistant, and write a [short bit of ESPHome yaml](https://github.com/paradox460/HomeAssistantConfig/blob/main/esphome/freezer-monitor-95cc6c.yaml) to configure it. Then mount it on your protoboard, and close up your case.

I glued the AHT module to the side of the case, and put some magnets on the back, so I could stick it to the side of my freezer.

I'd previously stuck the food simulant probe in my chest freezer, and fished the cord out through the back, so it wouldn't interfere with normal operation of the lid. I'd let it sit for 24 hours, so it was good and cold, and measuring it with a normal, non-connected thermometer reader (A ThermoWorks ThermaQ, in this case), saw my freezer was hovering around -1ºF, where I like to keep it. Disconnecting from the ThermaQ, and connecting to the extension that connects back to the MAX, I _should_ have been good to go.

## Calibration

Unfortunately, the temps I was seeing in my HomeAssistant were wrong. But they were _consistently_ wrong at the temperature ranges I wanted to read. I didn't need to calibrate for a large set of different temperatures, my probe was likely to only be reading temps around -5ºF to +5ºF, and so testing and finding the inaccuracies at this range is a lot easier.

I used a K-Type thermocouple simulator I spent far too much money on to generate temps around this level, and noted the difference that HA read from what the sim was generating.

Once I'd measured a decent enough cloud of points, I took the average of the offsets, which turned out to be -1º. Fortuitous.

ESPHome has a few different ways to calibrate a device. All the calibration systems use the filters system, which is a way to change or modify how a sensor in ESPHome works. There are linear calibrations, logarithmic calibrations, and more. They all take some data points, and use them to shift the signal accordingly. For my use case, since I was really just happy shifting the temp by a degree, I could just use a [simple `offset` filter](https://esphome.io/components/sensor/#offset).

For _all_ the sensors according to this board, I didn't want them to update too frequently, as you'd get noise on the graph. I had the update intervals set to 10 and 20 seconds, for various sensors, but even thats a little more frequent than I cared about. One nice way to smooth out a signal, and get accurate readings, is to use an exponential moving average, which [ESPHome provides as a nice filter](https://esphome.io/components/sensor/#exponential-moving-average)! Installing it on each module was simple, and I set it to basically average all the reads from the sensor over a minute. I had to tune the alpha factor a bit for each of them, but that was mostly trial-and-error until I got a result that I liked.

## State of the market 2025

Since building this, there are a few new products on the market that might be interesting to people wanting to do the same thing, without going the DIY approach. Sonoff has come out with a Zigbee based temperature probe, the [SNZB-02LD](https://amzn.to/43fhZbz) that has a _remote_ probe. You'd stick the transmitter/screen on the wall or side of your fridge, and the probe inside. No clue how well it works, but it's an option if you want something easy, and already are invested in the Zigbee universe.

You'll want to make sure you get one that has the external probe. The amazon listing seems to be an "updated" use of an old listing, for a probe-less model.

[ESPHome]: https://esphome.io/
