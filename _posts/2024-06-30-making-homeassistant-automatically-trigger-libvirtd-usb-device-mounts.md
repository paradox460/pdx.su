---
date: 2024-06-30T00:53:25.648031-06:00
title: Making HomeAssistant automatically trigger libvirtd USB device mounts
---

# Making HomeAssistant automatically trigger libvirtd USB device mounts

If you run HomeAssistant in a libvirt-based VM, such as in a qemu backed system, and you want to forward USB dongles (such as for z-wave or zigbee) from the host to the guest, you might run into issues where the dongle doesn't reconnect when the VM restarts, or when the host restarts. This can be quite frustrating, as any devices and automations you have that are tied to that dongle _will not work_ until you manually reconnect it to the guest.

## Manually

For a while, I was just doing the reconnects manually, via a simple little script:

```fish
#! /usr/bin/env fish

if test (whoami) != "root"
  echo "Must run as root" >&2
  exit 1
end

set -l cyme "/home/jeffs/.local/share/mise/installs/rust/latest/bin/cyme"
set -l serials XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

for serial in $serials
  set -l temp (mktemp /tmp/hass.XXXXXXXXXX)
  set -l usb_info ($cyme --filter-serial $serial --json)
  set -l busnum (jq -r '.[].location_id.bus' (echo $usb_info | psub))
  set -l devnum (jq -r '.[].location_id.number' (echo $usb_info | psub))

  echo -e "
<hostdev mode='subsystem' type='usb'>
  <source>
    <address type='usb' bus='$busnum' device='$devnum' />
  </source>
</hostdev>" > $temp

  while true
    virsh detach-device hass $temp; or break
  end
  virsh attach-device hass $temp
end

```

This script isn't really anything special; it uses [cyme](https://github.com/tuna-f1sh/cyme) instead of `lsusb`, as a previous incarnation of the script proved brittle around parsing the output of `lsusb`, and attempts to get the bus and device # of my two dongles (z-wave and zigbee), writes a quick temporary xml file for `virsh` to consume, and then asks virsh to detach any devices at that bus/device number, and then asks it to reattach them.

It runs through the detach step multiple times, as I've had issues with virsh getting _multiple_ attachments to a single bus/dev# in the past, exhausting the number of device passthroughs, and getting into an error state. It's probably not necessary, but I keep it around, as its harmless if it does nothing.

Running this script manually _still works_, but I don't want to have to shell into the host and run it every time there's a reboot to either the host or the guest, and so I looked at automating it

## UDEV rules

Initially, I tried running a variation of this script via udev rules, with the following udev rules file:

```text
# ZIGBEE
SUBSYSTEM=="usb", ATTRS{serial}=="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", RUN+="/usr/sbin/hass-reattach-usb.fish"
# ZWave
SUBSYSTEM=="usb", ATTRS{serial}=="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", RUN+="/usr/sbin/hass-reattach-usb.fish"
```

Those rules would dispatch the following script

```fish
#! /usr/bin/env fish

set -l logFile "/var/log/hass-usb-reattach.log"
set -l virshDomain "hass"
set -l tmpfile (mktemp)

set -l deviceType

switch $ID_SERIAL_SHORT
  case "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    set deviceType "Zigbee"
  case "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    set deviceType "Z-Wave"
  case "*"
    exit 0
end

if not set -q BUSNUM; or test -z "$BUSNUM"; or not set -q DEVNUM; or test -z "$DEVNUM"
  echo "NO SUCH LUCK BUDDY" >> $logFile
  exit 0
end


set -l hostdev "
<hostdev mode='subsystem' type='usb'>
  <source>
    <address type='usb' bus='$BUSNUM' device='$DEVNUM' />
  </source>
</hostdev>
"
set hostdev (string trim $hostdev)

printf $hostdev > $tmpfile

echo (date) ": (Re-)attaching $deviceType (B:$BUSNUM D:$DEVNUM)" >> $logFile

virsh detach-device "$virshDomain" "$tmpfile" &>1 >> $logFile || true
virsh attach-device "$virshDomain" "$tmpfile" &>1 >>

rm $tmpfile

exit 0
```

This worked in the case that the USB devices were added _after_ the VM was running. But it didn't work for initial boot of the host. Which was the biggest and originating problem I was trying to solve.

## libvirt hooks

libvirt has a [hooks feature](https://libvirt.org/hooks.html), where it will run certain hook scripts on the _host_ OS at various points. Of interest to us is the `started` point, for qemu.

I wrote up a variation of the first script, with some wrapper code to only dispatch on `started` events. Unfortunately, it never actually did what I needed it to do.

The script would run, and attempt to mount a device to the guest OS. But it would run too soon after the guest was started, and was unwilling to take new devices, and so would just hang there, eventually timing out, and not adding the new device, requiring a manual intervention.

I meant to post the script example I used here, but found out that I actually deleted it in frustration when it didn't work. You're not missing out on much, as the script was mostly just an if test to see if we're in a `started` event, an if test to see if the domain is one we care about, and then a dispatch to the manual script.

## Attaching the devices when HomeAssistant is online

If we look at what we're _actually_ trying to do here, we're trying to get these devices mounted in HomeAssistant. We don't really give a hoot about the underlying state of the guest OS, and so a libvirt status of `started`, the equivalent to a power light being illuminated on a physical machine, is of no real importance. If we could get HomeAssistant to somehow tell the host OS when it was ready, we could then run the attach script, and have everything just work.

A lot of people will use SSH to make their HomeAssistant guests talk to the host. I was a bit squeamish about this, it seemed like an easy way to open an attack vector, should my HomeAssistant installation get compromised somehow. I could ssh into a user with limited permissions on the host, but "limited" is a misnomer, as the user would still need access to libvirt, via the `virsh` command and the ability to query all the USB devices on the system. Not exactly a light set of permissions.

I also thought about setting up a small http server, which would handle dispatching the script when HomeAssistant calls it; essentially a webhook. While this would undoubtably be far more secure than full-blown SSH access, it wasn't really something I wanted to muck about with. I've had enough experience trying to tighten down a webhook to only respond to a "real" client, and ignore fake clients, that I didn't really want to muck with it for what should just be a simple process.

Finally, I realized that HomeAssistant's [MQTT integration](https://www.home-assistant.io/integrations/mqtt/) sends [birth and last-will messages](https://www.home-assistant.io/integrations/mqtt/#birth-and-last-will-messages) to `homeassistant/status`. I use [MQTT to monitor my power and gas meters](/blog/2024-03-17-reading-my-electric-meter-with-rtlsdr), as well as bringing real-time data from my WeeWX weather station into HomeAssistant, and so using it for something else was great. Having the `homeassistant/status` messages automatically emitted from HomeAssistant itself means I wouldn't have to create an automation to emit a message at boot, simplifying the number of moving parts.

Running a simple MQTT client, to listen to a particular topic, and run a small program when a message comes in on that topic, is fairly trivial. I used the [mosquitto_sub](https://mosquitto.org/man/mosquitto_sub-1.html) program, which comes with the `mosquitto-clients` on most linux distros. This program simply connects to a server, listens to a topic, and emits messages to stdout. A script to consume these messages, and dispatch the attach script, was rather simple:

```fish
#! /usr/bin/env fish
# You can run this by hand, but it expects to be run by a daemon
# see hass-device-passthrough-listener.service
set -l host homeassistant.local
set -l username vm-host
set -l password 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
set -l topic homeassistant/status

echo "Starting listener service"

mosquitto_sub -R -h $host -t $topic -u $username -P $password | while read -l line
  echo "[MSG] $line"
  if test $line = "online"
    echo "Attempting to run passthrough script"
    /home/jeffs/homeassistant/device-passthrough.fish
  end
end

```

Running the script, and sending fake online messages with the HomeAssistant MQTT publish service, worked beautifully. Since I wanted this to run _all the time_, from boot to shutdown, I whipped up a systemd service file, that starts it and keeps it running:

```systemd
[Unit]
Description="Hass device passthrough listener"
Requires=libvirtd.service
Requires=network-online.target
After=libvirtd.service

[Service]
Restart=always
RestartSec=30
ExecStart=/home/jeffs/homeassistant/mqtt-listener.fish

[Install]
WantedBy=multi-user.target
```

After getting this loaded and started with HomeAssistant, I brought down the VM by hand, and watched via `journalctl` as the script received a message, kicked off the attach script, and then went back to idling. After this test was successful, I restarted the whole host, and saw it work with success as soon as HomeAssistant was ready.
