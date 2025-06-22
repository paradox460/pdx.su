---
date: 2024-03-17T14:18:46.840827-06:00
updated: 2024-03-23T00:44:26-06:00
amazon: true
title: Reading my electric meter with RTLSDR
---

# Reading my electric meter with RTLSDR

As I dive deeper into HomeAssistant automations, one thing has been nagging at me: my energy usage statistics. I have a solar array, battery, and associated systems installed on my house, and they integrate somewhat well with HomeAssistant. However, due to the way my house was wired, the solar/backup system is only aware of power usage for roughly half the house; the air conditioner and some other heavy appliances are on a separate circuit, that I chose not to have backed up due to their heavy loads. As such, any statistics in HomeAssistant related to power were only partially true; they were missing an entire chunk of my annual power consumption, leading to the values reported in HA differing from the values reported on my bill. I wasn't terribly happy with this, and so over time I've been investigating solutions.

![My Energy Dashboard for March 17, 2024](/postimages/energy-dashboard.png)

## Background

### HomeAssistant's energy dashboard and integrations

Back in 2021, [HomeAssistant added a pretty robust energy integration](https://www.home-assistant.io/blog/2021/08/04/home-energy-management/). Their system could integrate with gas and electric systems commonly found throughout Europe, via a standard called P1. Unfortunately, we don't have that standard here in the USA. When that post came out, I looked it over with interest, saw that it wasn't applicable to the USA, and filed it away under the "some day" file.

There were approaches for pulling power usage information from US systems; some electric utilities provide an API for access to their data, and there are many such integrations built into HomeAssistant, ripe for the pickings. Other people use current-sensing clamps, placed around the power as it enters their breaker box, or, for more granular data, around each circuit as it leaves the breaker box. Still other solutions exist, such certain smart home products that integrate and try to read electrical usage signatures to determine what is using power, or OCR systems that use a camera to watch their electric meter directly. But none of these really appealed to me; I didn't want to shove a bunch of current sensing clamps around each wire in my breaker box[^1], and my meter is visible from the street, so a camera in a place that could accurately read the meter was a non-starter. So my usage mostly just stuck with the half accurate measures I was getting.

### Smart Meters in the USA

In the USA, most smart meters send data along the ISM band, in a protocol called Encoder Receiver Transmitter, by Itron corporation. This applies to electric, gas, and water meters. Said protocol has a variety of message formats, but they're all fairly easy to work with. The meters generally have a barcode or similar tag on them, usually near the word/logo for "Itron", with an 8 digit numeric ID.

### RTLSDR

I've been aware of RTLSDR for a while, always minorly interested in it, but never actually doing anything with it. I'd heard rumblings over the years that people were using it for all sorts of interesting use cases, such as modernizing old 433MHz burglar alarm systems, reading data from weather stations, and so forth. But what really piqued my interest was reports of people using it to read data sent from smart meters.

Basically, you use a cheap radio dongle, like a DVB-T television tuner, as the raw radio, and then software (the S in SDR) to process the data you get and make it useful.

Since the smart meter is going to send the data regardless of who is reading it, and it's the _actual data the electric company uses for billing_, it seemed a prime candidate for my usage.

### RTLAMR

There's an excellent GitHub project, which is the backbone of my setup, called [rtlamr](https://github.com/bemasher/rtlamr/). It works with data output via [rtl_tcp](https://osmocom.org/projects/rtl-sdr/wiki/Rtl-sdr) from the rtl-sdr project, to talk to one of the aforementioned cheap dongles, listening in for messages from meters, optionally filtering by meter IDs. When it sees a message it understands, it decodes it, and prints it out as a formatted JSON object.

If you're not sure of your meter, you can just listen for _all_ packets, and then pick yours out of the soup you get back.

Taking the outputted JSON data and sending it to HomeAssistant is a mostly trivial step, and there are already a few projects that do it.

## My Setup

### Prerequisites

First things first, you'll need a HomeAssistant installation running. You can still graph and chart all the data provided by rtlamr without it, but you're on your own.

With said HomeAssistant installation running, you'll also need to have the [MQTT](https://www.home-assistant.io/integrations/mqtt/) integration running with an MQTT Broker. I use [EMQX](https://github.com/hassio-addons/addon-emqx) becuase I like Erlang and graphs and everything else, but [Mosquitto](https://mosquitto.org) works just fine. HomeAssistant claims RabbitMQs MQTT features don't work well for their use cases, and I never spent the time to prove them wrong.

### The dongle



I purchased an [RTLSDR Blog v4](https://amzn.to/3Q4y8KZ) from Amazon.com, as these have had good reviews over the years, and provide a nice _clean_ data stream. People have had good luck with DVB-T shields for RPis, or USB DVB-T shields, but the price difference isn't that great, and so I went with a device I _knew_ would work. I purchased the dongle _without_ an antenna, as I wasn't quite sure where I was going to operate it. I have a few SMA connector antennas lying around, from other projects, but ultimately I went and bought a small antenna from a local RadioShack[^2] for this. There are many antennas that will work with this on Amazon, such as [this one](https://amzn.to/3Uh0BQ8), which looks very similar to the one I purchased from RadioShack. You just want to make sure the antenna you purchase works well in the 900MHz frequencies.

When you actually get the dongle, it's rather uneventful for setup. Plug it into your computer of choice, be it an RPi, server, or whatever else. You _don't have to run this on the same machine HomeAssistant is running on_. If you can't see the meter's readings where your server is, you can put the dongle/antenna on an RPi or other small computer in a place that can see the readings, as it will talk to HomeAssistant via MQTT.

### HomeAssistant Integration

Searching around the internet lead me to [this repo by RagingComputer](https://github.com/ragingcomputer/amridm2mqtt). It looked like it might do _exactly_ what I wanted; that is, package up RTLSDR, RTLAMR, and a bit of code to send messages across MQTT. However, in experimentation I was unable to get it running. There was an issue reported to the GitHub repo already, from two years ago, and the last commit was four years ago, so I figured the project was dead.

Feeling a bit lazy, I didn't really want to fork and fix it myself, so I set out to see if anyone else had solved it. Enter Allan Gomez GooD. He's got [an excellent repo](https://github.com/allangood/rtlamr2mqtt) that does the same thing as the amridm2mqtt repo, but has gone the extra mile and built it out as a custom HomeAssistant addon. If you're running the dongle on the same system as your HomeAssistant installation, this is perfect. You can install the whole addon with a couple of clicks, and there are even [big friendly buttons](https://github.com/allangood/rtlamr2mqtt#home-assistant-add-on) in the readme for doing just that.

If you run it on a separate computer, It's not much more complex, and the [readme covers that as well](https://github.com/allangood/rtlamr2mqtt#docker-or-docker-compose)

### Configuring RTLAMR

Once you get it installed, either via HomeAssistant or as its own thing, you need to configure it. Configuration is rather straightforwards, and well documented.

For me, I went into EMQX and set up a custom user account for RTLAMR to send data to my MQTT system with. It can read and use the credentials HomeAssistant already has in its built in MQTT integration, but I like to keep things separated out; makes debugging and security easier.

Once I had that part configured, I had to figure out what meters were mine. I knew the number of my meter, it's printed on the front of the device, but that's where my knowledge stopped. I didn't know what format of messages it would send, and I didn't know how it would represent the data for import vs export (remember, I sell solar power _back_ to the electric company). How would I figure this information out?

Fortunately, RTLAMR has you covered. There's a mode for listening to all meters, that can be dispatched as a one-off docker command:

```sh
docker run --rm -ti -e LISTEN_ONLY=yes -e RTL_MSGTYPE="all" --device=/dev/bus/usb:/dev/bus/usb allangood/rtlamr2mqtt
```

Running that on the machine with the dongle attached, you'll see the raw JSON messages as they are decoded. In my case, I saw big clusters of about 10 messages every 2 minutes, and then every 10 minutes or so I saw an even larger cluster of different messages.

Looking _into_ the messages, I saw one message that had my meter number on it, along with a reading that was pretty close to what was on the front of the meter:

```json
{
  "Message Type": "SCM",
  "ID": #######4,
  "Type": 8,
  "TamperPhy": 0,
  "TamperEnc": 0,
  "Consumption": 1552536,
  "ChecksumVal": #####
}
```

But immediately following that, I saw two more messages, with their IDs just incremented off mine by 1 each time

```json
{
  "Message Type": "SCM",
  "ID": #######5,
  "Type": 8,
  "TamperPhy": 0,
  "TamperEnc": 0,
  "Consumption": 644391,
  "ChecksumVal": #####
}
{
  "Message Type": "SCM",
  "ID": #######6,
  "Type": 8,
  "TamperPhy": 1,
  "TamperEnc": 1,
  "Consumption": 908145,
  "ChecksumVal": #####
}
```

The message with the ID ending in 5 turned out to be my _export_, and the message ending with the 6 was the delta between the import and export. Why they send all three is a question for the power company. With the information I had, I could configure RTLAMR. My message type was SCM, and I had the two IDs for the meters I wanted. Entering those values in the config, I exited the listen all mode, and started up the HomeAssistant integration.

2 minutes later I had a reading, and my data was now ready to use.

I spent a bit more time faffing about trying to find an interval that didn't leave RTLAMR always listening, while keeping the data fairly fresh. By default, it sleeps for 5 minutes (300s) after a successful packet read, but through using the LISTEN ALL mode, I discovered my meter sends pretty accurately every 2 minutes. Since 5 does not divide cleanly into 2, I set my sleep interval to just shy of 120 seconds, so I'm getting every packet my radio sends, without wasting much effort.

You could probably do something similar just by watching the MQTT messages, using something like [MQTT Explorer](https://mqtt-explorer.com), but be aware of one caveat. If your meter doesn't report a change in the value, then no message will be sent to MQTT. I'm not sure if this is my server dropping duplicate messages or a feature built into the RTLAMR system I'm using, but it does reduce network congestion, so I'll take it.

If you leave the default configuration the addon came with, it will _automatically_ create new sensors in your HomeAssistant install for all the meters you've added. If it doesn't see a meter you've told it to watch for, it won't add it _till it sees it_. This is the current situation of my Gas Meter, which I suspect only reports data when polled.

### Configuring HomeAssistant

#### Without Tariff Data

If you don't care about how much your utility usage _costs_, or just have a single flat rate, I envy you. You get a much simpler configuration.

Head over to your [Energy dashboard](https://my.home-assistant.io/redirect/energy/) in your HomeAssistant installation, and open up the config page. Under the relevant section, in my case Electricity Grid, add your relevant meters. For me, it _would_ be the import meter under the consumption section, and the export meter under the Return to Grid section.

And that's it. You now have usage stats reported accurately. In a few hours, you'll see accurate usage information.

#### With Tariff Data

This is a somewhat more complicated flow, and involves the setup of multiple [Utility Meter helpers](https://www.home-assistant.io/integrations/utility_meter/), automations, and more. But if you want to get as accurate a picture of your costs, its worth it.

For me, my electric company breaks things down into a few tariff structures for purchasing:

+ **Summertime**
  + **First 400 kWh**: $0.090279 / kWh
  + **All additional power**: $0.11721 / kWh
+ **Wintertime**
  + **First 400 kWh**: $0.079893 / kWh
  + **All additional power**: $0.103725 / kWh

There's a similar, but simpler, pricing structure for export power:

+ **Summertime**: $0.05636 / kWh
+ **Wintertime**: $0.04745 /kWh

When I was just running the powerwall data, I made use of a [template](https://github.com/paradox460/HomeAssistantConfig/blob/ff9980fb0bb3b32fbe089d215ed03949da99d6cc/templates/energy_rates.yaml) that just tracked time and cumulative usage from a single "utility meter" integration that reset with my billing period, and flip-flopped depending on the data, but this had the flaw that it wasn't accurately tracking the difference between the first 400 kWh and the remaining power usage. As soon as it flipped to the "higher" usage numbers, it could throw off older calculations.

The "right" way to do this is by creating utility meters for _each_ bin of power usage, and using an automation to switch the currently active utility meter.

##### Utility Meters

For my use case, I set [up 5 utility meters](https://github.com/paradox460/HomeAssistantConfig/blob/bbaf7a4164ed67e2ee8d808e3695e875f763bc71/utility_meter.yaml), although you could make due with 3. I just like to have the extra day tracking for my own purposes.

I've set my utility meters to reset on the 27th, as that's the end of my billing cycle. I then create two meters, one that has tariffs applied, and one that does not. The one without tariffs is used to just track cumulative usage across the whole period. The meters with tariffs configured will actually show up as multiple different meters in HomeAssistant. Sure, you could sum up the values of the current seasonally active meters to get your 400 kWh threshold, but doing that logic in templates or automations is always a little more brittle than I like.

Once you've got the meters set up and have reloaded your HomeAssistant config, you should add _all_ the tariff'd meters to your [Energy Dashboard Config](https://my.home-assistant.io/redirect/energy/) along with their pricings as _fixed_ values.

To switch between the bins, use an automation.

##### Active Meter Automation

You can do this pretty easily with native HomeAssistant Automations, but I didn't. I prefer to use NodeRed for my automations, and came up with something like this.

![NodeRed graph showing the power meter automation](/postimages/nodered-power-automation.png)

The "Set Season Daily" group starts with a timer that triggers every night at midnight, as well as on startup. This triggers a JavaScript function, which sets a NodeRed flow variable "summer" to a boolean true or false, depending on the current date. This JS function also splits output to two branches, depending on summmer. From these two branches, the current bin for the export power tariffs are set via a pair of select option service calls.

The Trigger state block in the Set Import Tariff group outputs depending on if the monthly meter without any tariff data reports greater than 400 kWh. Both branches, the greater than 400 kWh and the less-than, output to a switch statement, which reads the previously set flow variable for "summer time", and then calls a select option service call that sets the active buckets for the two import utility meters.

<details>
<summary>The NodeRed flow is available here</summary>

```json
[{"id":"7030ec85714e521d","type":"tab","label":"Electricity Tariffs","disabled":false,"info":"","env":[]},{"id":"c2be4e7700b3d8e5","type":"group","z":"7030ec85714e521d","name":"Set Season daily","style":{"label":true},"nodes":["163ac22ed1d95d60","51c6c4d86a4f87b8","1f1ac14da602b108"],"x":34,"y":293,"w":618,"h":174},{"id":"1d6ef5cec40e2629","type":"group","z":"7030ec85714e521d","name":"Set Import Tariff","style":{"label":true},"nodes":["02ad35cf4db4cbd1","4bfdf3be32ae39ac","29c18e062e55fe14","ac28a1977f2b43f6","05cce05de54f7613","871107a9446c7041","35a21073487e74fc"],"x":34,"y":19,"w":972,"h":242},{"id":"1f1ac14da602b108","type":"group","z":"7030ec85714e521d","g":"c2be4e7700b3d8e5","name":"Set export tariff","style":{"label":true},"nodes":["0af23044806f9006","03d08d57cb753206"],"x":454,"y":319,"w":172,"h":122},{"id":"163ac22ed1d95d60","type":"eztimer","z":"7030ec85714e521d","g":"c2be4e7700b3d8e5","name":"","debug":false,"autoname":"0:00:00","tag":"eztimer","topic":"","suspended":false,"sendEventsOnSuspend":false,"latLongSource":"haZone","latLongHaZone":"zone.home","lat":"41.1145565060444","lon":"-111.91224648624485","timerType":"2","startupMessage":true,"ontype":"2","ontimesun":"dawn","ontimetod":"0:00:00","onpropertytype":"msg","onproperty":"payload","onvaluetype":"num","onvalue":1,"onoffset":0,"onrandomoffset":0,"onsuppressrepeats":false,"offtype":"1","offtimesun":"dusk","offtimetod":"dusk","offduration":"00:01:00","offpropertytype":"msg","offproperty":"payload","offvaluetype":"num","offvalue":0,"offoffset":0,"offrandomoffset":0,"offsuppressrepeats":false,"resend":false,"resendInterval":"0s","mon":true,"tue":true,"wed":true,"thu":true,"fri":true,"sat":true,"sun":true,"x":120,"y":360,"wires":[["51c6c4d86a4f87b8"]]},{"id":"51c6c4d86a4f87b8","type":"function","z":"7030ec85714e521d","g":"c2be4e7700b3d8e5","name":"function 1","func":"const month = new Date().getMonth();\n\nif (month >= 5 && month <= 9) {\n    flow.set('summer', true);\n    return [{payload: true}, null];\n} else {\n    flow.set('summer', false);\n    return [null, { payload: true }];\n}\n\n","outputs":2,"timeout":0,"noerr":0,"initialize":"// Code added here will be run once\n// whenever the node is started.\nconst month = new Date().getMonth();\n\nif (month >= 5 && month <= 9) {\n    flow.set('summer', true)\n} else {\n    flow.set('summer', false)\n}","finalize":"","libs":[],"x":280,"y":360,"wires":[["0af23044806f9006"],["03d08d57cb753206"]],"outputLabels":["summer","winter"]},{"id":"02ad35cf4db4cbd1","type":"trigger-state","z":"7030ec85714e521d","g":"1d6ef5cec40e2629","name":"","server":"ffea7422.3895a8","version":4,"inputs":0,"outputs":2,"exposeAsEntityConfig":"","entityId":"sensor.electricity_import_month_total","entityIdType":"exact","debugEnabled":false,"constraints":[{"targetType":"this_entity","targetValue":"","propertyType":"current_state","propertyValue":"new_state.state","comparatorType":">=","comparatorValueDatatype":"str","comparatorValue":"400"}],"customOutputs":[],"outputInitially":false,"stateType":"num","enableInput":false,"x":250,"y":120,"wires":[["4bfdf3be32ae39ac"],["29c18e062e55fe14"]],"outputLabels":["gte 400","lt 400"]},{"id":"4bfdf3be32ae39ac","type":"switch","z":"7030ec85714e521d","g":"1d6ef5cec40e2629","name":"is summer","property":"summer","propertyType":"flow","rules":[{"t":"true"},{"t":"false"}],"checkall":"true","repair":false,"outputs":2,"x":710,"y":80,"wires":[["ac28a1977f2b43f6"],["05cce05de54f7613"]]},{"id":"29c18e062e55fe14","type":"switch","z":"7030ec85714e521d","g":"1d6ef5cec40e2629","name":"is summer","property":"summer","propertyType":"flow","rules":[{"t":"true"},{"t":"false"}],"checkall":"true","repair":false,"outputs":2,"x":710,"y":200,"wires":[["871107a9446c7041"],["35a21073487e74fc"]]},{"id":"ac28a1977f2b43f6","type":"api-call-service","z":"7030ec85714e521d","g":"1d6ef5cec40e2629","name":"summer gt 400","server":"ffea7422.3895a8","version":5,"debugenabled":false,"domain":"select","service":"select_option","areaId":[],"deviceId":[],"entityId":["select.energy_import_day","select.energy_import_month"],"data":"{\"option\":\"summer_gt_400\"}","dataType":"jsonata","mergeContext":"","mustacheAltTags":false,"outputProperties":[],"queue":"none","x":900,"y":60,"wires":[[]]},{"id":"05cce05de54f7613","type":"api-call-service","z":"7030ec85714e521d","g":"1d6ef5cec40e2629","name":"winter gt 400","server":"ffea7422.3895a8","version":5,"debugenabled":false,"domain":"select","service":"select_option","areaId":[],"deviceId":[],"entityId":["select.energy_import_day","select.energy_import_month"],"data":"{\"option\":\"winter_gt_400\"}","dataType":"jsonata","mergeContext":"","mustacheAltTags":false,"outputProperties":[],"queue":"none","x":890,"y":100,"wires":[[]]},{"id":"871107a9446c7041","type":"api-call-service","z":"7030ec85714e521d","g":"1d6ef5cec40e2629","name":"summer lt 400","server":"ffea7422.3895a8","version":5,"debugenabled":false,"domain":"select","service":"select_option","areaId":[],"deviceId":[],"entityId":["select.energy_import_day","select.energy_import_month"],"data":"{\"option\":\"summer_lt_400\"}","dataType":"jsonata","mergeContext":"","mustacheAltTags":false,"outputProperties":[],"queue":"none","x":850,"y":180,"wires":[[]]},{"id":"35a21073487e74fc","type":"api-call-service","z":"7030ec85714e521d","g":"1d6ef5cec40e2629","name":"winter lt 400","server":"ffea7422.3895a8","version":5,"debugenabled":false,"domain":"select","service":"select_option","areaId":[],"deviceId":[],"entityId":["select.energy_import_day","select.energy_import_month"],"data":"{\"option\":\"winter_lt_400\"}","dataType":"jsonata","mergeContext":"","mustacheAltTags":false,"outputProperties":[],"queue":"none","x":840,"y":220,"wires":[[]]},{"id":"03d08d57cb753206","type":"api-call-service","z":"7030ec85714e521d","g":"1f1ac14da602b108","name":"winter","server":"ffea7422.3895a8","version":5,"debugenabled":false,"domain":"select","service":"select_option","areaId":[],"deviceId":[],"entityId":["select.energy_export_day","select.energy_export_month"],"data":"{\"option\":\"winter\"}","dataType":"jsonata","mergeContext":"","mustacheAltTags":false,"outputProperties":[],"queue":"none","x":530,"y":400,"wires":[[]]},{"id":"0af23044806f9006","type":"api-call-service","z":"7030ec85714e521d","g":"1f1ac14da602b108","name":"summer","server":"ffea7422.3895a8","version":5,"debugenabled":false,"domain":"select","service":"select_option","areaId":[],"deviceId":[],"entityId":["select.energy_export_day","select.energy_export_month"],"data":"{\"option\":\"summer\"}","dataType":"jsonata","mergeContext":"","mustacheAltTags":false,"outputProperties":[],"queue":"none","x":540,"y":360,"wires":[[]]},{"id":"ffea7422.3895a8","type":"server","name":"Home Assistant","version":5,"addon":true,"rejectUnauthorizedCerts":true,"ha_boolean":"y|yes|true|on|home|open","connectionDelay":true,"cacheJson":true,"heartbeat":false,"heartbeatInterval":30,"areaSelector":"friendlyName","deviceSelector":"friendlyName","entitySelector":"friendlyName","statusSeparator":"at: ","statusYear":"hidden","statusMonth":"short","statusDay":"numeric","statusHourCycle":"h23","statusTimeFormat":"h:m","enableGlobalContextStore":true}]
```

</details>


## Closing

I haven't yet got my water or gas meters integrated into this system. I plan on doing that eventually, but for now I'm happy with the electric results. The data won't be the most accurate for the remainder of this billing period, but it _should_ reflect my next billing period fairly accurately, and I plan to check it.

## Updates

### 2024-03-23
Since the article was published, my system picked up some messages from my gas meter, and now has a gas meter chart. I'd misconfigured the decimal place in rtlamr, and so had to dump my old readings and set it up again. I'll eventually set out to figure out a way to track gas tariffs and get estimates in there for now.

I spent some time tonight setting up the [digital-alchemy](https://docs.digital-alchemy.app) add-on for HomeAssistant. It lets you write automations using typescript, with some nice tooling for VSCode or other typescript language server compatible editors. [I ported my tariff switching logic out of NodeRED and into typescript](https://github.com/paradox460/HomeAssistantConfig/blob/739ae0618bb57620bfd7c33457e9a742d4b04e01/typescript/src/electricity-tariffs.ts), and find the end result much simpler to reason about. I'll probably wind up doing the same style script for my gas tariff tracking.


[^1]: Seriously, have you seen some of these installs? They look like horrific rats nests!
[^2]: I'm so ridiculously fortunate to have one of the few remaining RadioShacks nearby, so I try to get as much as I can justify from them, to help keep them afloat.
