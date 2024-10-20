---
date: 2024-10-20T13:03:12.162467-06:00
amazon: true
---

# Integrating old GE Interlogix Burglar Alarm sensors into HomeAssistant with SDR

Previously, when I was setting up [SDR to read my utility meters](/blog/2024-03-17-reading-my-electric-meter-with-rtlsdr/), while doing research into various tools for reading data with an SDR, I stumbled across a description of some home burglar alarm systems, and how they send data in an easily readable format. This piqued my interest, but I ultimately ignored it at the time, as I was already down a rabbit hole with the utility meters, and wanted to finish that project first. Now, its several months later, and I dove back down that rabbit hole, and within a few hours was able to get a system working quite well.

My house was built in the mid-90s, when Home Automation meant a mixture of an intercom system, burglar alarm, and maybe some X10 stuff (I didn't find any of that, sadly). State-of-the-art burglar alarm systems at the time used cheap little radio transmitters, to avoid the need of running wires all over a house.[^1] These devices typically take the form of a little box next to a door or window, with a reed switch that is triggered by a magnet attached to the door or window. And my house is chock-full of them.

[^1]: They _still_ use radio transmitters for modern burglar alarm systems, but most of them have moved away from simple systems like this to things such as Zigbee or Z-Wave. A large number of the "DIY-ish" ones also rely on Wi-Fi as their network.

![This unobtrusive little box contains a door sensor](/postimages/2024-10-20-integrating-old-ge-interlogix-burglar-alarm-sensors-into-homeassistant-with-sdr/PXL_20241020_173540372.jpg)

![Cover off, we can see it's a fairly simple little PCB](/postimages/2024-10-20-integrating-old-ge-interlogix-burglar-alarm-sensors-into-homeassistant-with-sdr/PXL_20241020_182129577.jpg)

However, looking at these sensors from the outside, they are somewhat hard to decipher. Although their immediate function is readily clear to most people who would care about this sort of thing, how to get the information out of them is somewhat more obscure. Fortunately, smart people on the internet have [documented the messages these little boxes put out](https://github.com/merbanan/rtl_433/blob/master/src/devices/interlogix.c), and written tools that can decipher them.

One such tool is the excellent [rtl_433]. This tool is a little Swiss army knife of SDR. You can use it for all sorts of things, like reading cheap wireless temperature sensors, using cheap keyfob remotes for input devices, and more. You'll need an SDR, and the [RTLSDR] I used before sadly won't cut it this time. These sensors transmit at 319.5MHz, and the [RTLSDR] just couldn't receive them. Fortunately, there's a low-priced and _excellent_ SDR that _can_ read them: The [Nooelec NESDR][nesdr].

## Setup

The [nesdr] is more or less plug and play. Once you have [rtl_433] installed, It's pretty much just a matter of calling the right program with the right arguments, and you should immediately start seeing results.

On the physical side, your [nesdr] may come with a few different lengths of antennas. This little device can be used to listen in on a very wide variety of frequencies, and so the antennas bundled with it have different uses. To find the ideal, or near ideal, antenna length for a frequency, we use a bit of simple math to get the quarter-length antenna, which tells us we need an antenna about 9.2 inches long. My [nesdr] came with one about this length, so I used that one

Software wise, it couldn't be easier. Assuming you have [rtl_433] installed, simply fire it up, listening on 319.5MHz, with the protocol set to `100`[^3]:

```sh
rtl_433 -f 319.5M -R 100
```

[^3]: The [rtl_433] docs tell us that protocol 100 is GE Interlogix. This is who made my sensors. If you're using different wireless sensors, you may have to use a different protocol.

After firing up this, you'll get a console that seems rather quiet, after the initial messages. Go over and trigger one of these sensors (open a door). You should see a message appear in the console, describing a sensor, several switches, and maybe even a battery state. When you close the door, you should see a similar message, but one of the switches should have changed state. That's your door sensor. If you don't see anything, check the battery on the unit. Many of my units _still_ have good batteries in them, despite the batteries being well over 10 years old.

Now we need to get that information into HomeAssistant.

## MQTT

[rtl_433] has _built in_ MQTT support, which is the best way to get the information from the sensors into HomeAssistant. You'll need to have an MQTT broker system running, which is beyond the scope of this article, but not terribly complex. Assuming you do have one running, simply modify the command we ran previously to resemble this one:

```sh
rtl_433 -f 319.5M -R 100 -F mqtt://your-broker-hostname:1883,user=broker_user,pass=broker_pass
```

Fire up a tool like [MQTT Explorer], and trigger one of the sensors. You should see a message fairly quickly

![My network is rather noisy, with many sensors happily reporting away](</postimages/2024-10-20-integrating-old-ge-interlogix-burglar-alarm-sensors-into-homeassistant-with-sdr/CleanShot 2024-10-20 at 12.17.28@2x.png>)

Once you see those messages on your MQTT network, we can get them into HomeAssistant. In your HomeAssistant configuration, you'll need to add something similar to this yaml:

```yaml
mqtt:
  cover:
    - name: "Front Door"
      unique_id: "front_door"
      device_class: "door"
      state_topic: "rtl_433/server/devices/Interlogix-Security/contact/af42c7/switch5"
      state_closed: "CLOSED"
      state_open: "OPEN"
      device:
        name: RTL433
        identifiers: "RTL433 sensor"
```

You'll want to add one of those for each unit you want to detect. I recommend watching the network with [MQTT Explorer] and go around triggering each sensor, noting down its ID, and then setting up each cover entry.

Once that's all done, reload your HomeAssistant config, and you're done! You now have your door, window, heat, glass break, and any other sensors you cared to map in HomeAssistant.
![HomeAssistant history for my front door sensor](</postimages/2024-10-20-integrating-old-ge-interlogix-burglar-alarm-sensors-into-homeassistant-with-sdr/front door history.jpg>)

[rtl_433]: https://github.com/merbanan/rtl_433/
[RTLSDR]: https://amzn.to/3Q4y8KZ
[nesdr]: https://amzn.to/4fc3Jo5
[MQTT Explorer]: https://mqtt-explorer.com
