---
date: 2024-08-10T21:43:16.214534-06:00
updated: 2024-12-25T20:00:18-07:00
amazon: true
title: DIY Permanent Xmas lights
---

# DIY Permanent Xmas lights

![My house with Red White and Blue lights for the fourth of july](/postimages/permanent_leds/houselights.jpg)

Here in Utah, an increasingly common sight is houses with permanent "Christmas" lights. These are usually installed using aluminum channels, along the roofline, and make use of color-changing LEDs. Several of my neighbors have had them installed professionally, and I've always wanted something similar. However, the prices, and limitations, that come with professional installations, are often prohibitive.

## Professional installations

Several companies have nation-wide and local footprints for installing these lights. Companies such as Jellyfish lighting, everlights, and trimlight seem to be the biggest players in the space, but I'm sure most roof and gutter companies will offer similar products as a service. They have the installations of these things down to a science; a contractor will come out, measure the areas you want lit, and leave. A while later, usually about a week, they'll come back with some workers, precut channels and lights, and a control system, and get the whole thing installed in an afternoon. Their products will usually come with a warranty, and will generally work pretty reliably. If you just want some lights _now_, they're pretty much unbeatable in that regard.

But all that convenience comes with some very major limitations. Limitations that, for a tinkerer like myself, are game breakers. First, they typically only offer _one_ type of lighting, and that's pixel lighting. Generally these pixels can _only_ do RGB, no white channel, meaning any whites you get are the odd looking not-white-white we see from other RGB leds, such as those in gaming keyboards and mice. Second, they very rarely have open control software. All of my neighbors installs are limited to _only_ the official app, and require internet access to work. Some of them have mumblings about APIs on their website, but a few hours of research turned up very little more than "contact us for API questions."[^1] You can forget about controlling those lights with HomeAssistant.

[^1]: It's my opinion that any API that requires contacting someone to get set up is not an open API, and shouldn't be relied on unless there is a contractual guarantee of said API's availability. Think SLAs.

Finally, they are all absurdly costly. Several thousand dollars at the bottom end, up to tens of thousands at the upper. I can do better, for less.

## The state of DIY LED control circa 2024

Fortunately, unlike a lot of other DIY projects, this is a firmly entrenched, established, and catered-to market. There is a massive nation-wide (and international) community of people who do large holiday light shows, complete with music synchronization, permanent led installs, and more. There are many vendors, and products, targeting this segment, and most of them are open, ranging between just using standardized control protocols, to being fully open-source, with the ability to literally build your own controllers using simple, off the shelf parts, like ESP32s.

The biggest utilities in this space are a few software packages, that drive everything else; [xLights], [WLED], and [ESPixexStick][esps]. The former is useful for sequencing light shows, and is beyond the scope of this article, but well worth a look if you're into that thing. The latter two are the most interesting. [WLED] is ultimately what I wound up using, as [ESPixelStick][esps] is meant more for interfacing with an xLights defined show.

For control hardware, there are a variety of options to choose from, but by far the most widespread and established are the Dig series of controllers from [Intermittent Tech][it]. These packages provide a nice set of common requirements for LED control, built around an ESP32. You flash them with either WLED or ESPixelStick, depending on your needs.

As for the lights themselves, you have a dizzying amount of options. There are the common WS281x series LED packages, which are what commonly drives the pixels, packages that support RGBW, such as the SK6812, COB packages (aka LED Neon, very cool), strips, and even newer ones that not only have white LEDs on-board, but multiple white LEDs in addition to multiple color LEDs, so you can adjust the temperature of the white light as well. They all come in various packages too, from simple strips, to strings of "pucks", to stringers (hanging bulbs).

For attaching them to structures, there are nearly as many options as there are light configuration. If you're using pixels, one of the best options is probably [PermaTrack], although plenty of other track systems for pixels exist. If you're doing strips, you can buy channels with diffusers that sit over them, spreading the lights out. And some don't even need a channel, such as the larger pucks, which can be screwed directly into a soffit.

## My Setup

### What I wanted to accomplish.

At the outset, I had a few goals in mind. I wanted lights along the eaves of the _entire_ front of my house. I didn't need lights along the windows, garage doors, or pillars, just trim. Same as if I were brave enough to hang up old-fashioned C9s every year. They had to have a white light channel, in warm white (3000k or lower), as I frequently just want to light up the trim with simple white lights, and they had to be supported by WLED. You might think this constrained me, but in reality, it didn't. This is a fairly common ask, and nearly every single LED configuration out there has some capacity to be used in this.

Initially I wanted to use strips. I wasn't a tremendous fan of the bullet "pixel" look that the commercial installers went with, and thought having a higher density of lights might look better. I'd seen some youtubers I follow talk about how they liked using strips as well, and so it seemed a forgone conclusion for me. I bought a roll of COB LEDs, just to see how they looked, and while they look very cool, the color density was still somewhat low, with one color every 7cm or so.

![COB LEDs showing the great color, but 7cm wide bands](/postimages/permanent_leds/cob_led.jpg)

I've kept these for a future project, as they just look amazing.

From there, I needed a controller, and so I purchased a [Dig-Octa]. This neat little board is stackable, meaning you can put multiple power routing boards alongside multiple LED controller boards, and have everything working in a nice package. I only needed the capacity of one "brain board" and one power board.

![Dig-Octa on my test bench](/postimages/permanent_leds/dig_octa.jpg)

Finally, I needed some power supplies. I bought a pair of [Mean Well UHP-350-5 350W 5vdc](https://amzn.to/3yoNkgB) power supplies. These were based on a back-of-the-envelope calculation on how much power I'd need at peak, based on some [power tables](https://quinled.info/2020/03/12/digital-led-power-usage/) published by the guy behind the [Dig-Octa].

All in all, here's what I initially planned to use:

- 55m of SK6812 RGBWW (warm white) strips
- [2 power supplies](https://amzn.to/3yoNkgB)
- 1 [Dig-Octa] brain board and power board
- Aluminum channels and diffusers for the strips to be screwed to my soffits
- [Plastic enclosure purchased from amazon](https://amzn.to/3X0ciwb)

### Changing tracks

Wanting to make sure I was doing everything right, I joined a community for this, and asked some questions there. I relayed what I was planning to do, and was quickly advised against using 5v and using strips. Strips are no-good because they are rather difficult to work with, particularly up on a roof, and tend to have somewhat high failure rates. If you get an IP68 rated strip, which you _should_ if you're using them outside, splicing out a bad pixel is a tedious affair, that involves razors, soldering, wire cutters, a hot glue gun, and heat shrink tubing. And using 5v, while functional, means you have to do a lot more power injection[^2] than you would with higher voltages.

[^2]: With lower voltages, you lose more energy across longer runs of wire to heat, due to the resistance of said wire. This is known as voltage drop. When you have a load on that wire, such as LED lights, they also consume energy, and towards the end of a longer run of LEDs, you wind up with weird behaviors, such as bulbs lighting intermittently, bulbs lighting the wrong color, not responding to data codes, and so forth. You solve this by periodically _injecting_ power.

When asking what I should do instead, I was advised to check out a particular LED puck product, that came with channels and pucks. These pucks _are_ available in RGBWW, have 3 LEDs per puck, and run at 12V. The 3 LEDs per puck makes these suckers bright, and the packages themselves are fairly easy to work with. And the channels are a fairly simple aluminum affair, with a backplate that you attach to your soffit, and then a front, where the pixels snap into holes, that snaps into the back plate.

Fortunately, I hadn't bought much more than a single strip of LEDs and the two power supplies, and so this pivot wasn't too difficult. I couldn't use either for this project, but thats acceptable, as they were useful enough they wouldn't spend too long in the spare parts bin.

So, with these changes, my new parts list wound up looking like this:

- 55m of [LED pucks](https://www.aliexpress.us/item/3256807344866216.html)
- 55m of [aluminum channels](https://www.aliexpress.us/item/3256804734568668.html)
- [1 12v power supply](https://amzn.to/3Am4PyD)
- 1 [Dig-Octa] brain board and power board
- 1 [Plastic enclosure purchased from amazon](https://amzn.to/3X0ciwb)

I placed the order, and awaited delivery, which came a surprisingly short period later.

### Staging everything

Upon receipt of the huge box of tracks, pucks, and other assorted items, I set to work on the floor of the living room. I flashed an updated version of [WLED] to my dig-octa, and started testing each string of LEDs I'd received.

![Dig-Octa and the PSU as part of a "test bench"](/postimages/permanent_leds/dig_octa_and_psu.jpg)

![Testing a string of LED pucks](/postimages/permanent_leds/testing_leds.jpg)

Once they were tested, my wife and I installed them into the aluminum tracks

![Lights tested and installed in aluminum tracks](/postimages/permanent_leds/lights_in_tracks.jpg)

While testing them, I read more about the [Dig-Octa], and found out that it supports a relay and an auxillary power source. This lets you turn off the big 12v 600W power supply, and thus turn off the LEDs, while still keeping the brain board active. The brain board will actuate the relay whenever it is toggled.[^3]

[^3]: Additionally, when RGB LEDs of this type are "off", they're only off in the most technical of senses. Off is just a 0 value on all the channels a "light" listens to. Power is still flowing through them, but the chip that controls an LED or group of LEDs is choosing not to illuminate them. If you use a relay to control the power supply, off is off, no power will flow.

I purchased a bunch of generic Chinese [solid-state "relays"](https://amzn.to/3WYHJXt) off amazon, and got one of them wired up to toggle the power supply on and off:


![Relay getting wired up](/postimages/permanent_leds/relay.jpg)

Finally, when all the LEDs were tested, I moved everything into an enclosure, and got it all bolted down nice and secure. This enclosure will keep things dry and clean, although I mounted it in a location where there wouldn't be much risk of dust or water ingress

![Enclosure with PSU and Brain Board](/postimages/permanent_leds/box.jpg)

A period after taking this picture, I actually wired in a small plug _inside_ the box[^mini-psu], to plug a USB module into, so as to minimize the amount of wires going in and out of the box.

[^mini-psu]: Since building this box, I've built a couple more, for other projects, and have figured out better ways to power things. I've largely switched to using [these](https://amzn.to/3Ya8Kb3) little tiny power supplies for the 5vdc the ESP32 requires. They're extremely small, and fairly reliable.

Finally, it was time to start the installation

### Installation

Installation was fairly simple, albeit somewhat labor intensive. We started off by taking the backing of the tracks outside, lining them up along the roof, climbing up on a ladder, and screwing them into the soffit using self-cutting screws. I have metal soffits, so this worked reasonably well, but if I'd wooden soffits it would have been even easier. For corners, where a single 1m long track wouldn't fit, we cut the tracks, and the channels that snapped into them, with a miter saw. Aluminum is a nice soft material.

![Cutting track with a miter saw](/postimages/permanent_leds/miter_saw.jpg)

![Tracks on the soffit, no LEDs yet](/postimages/permanent_leds/tracks.jpg)

Once we got all the back tracks installed, it was time to install the front tracks. Given we'd need a couple power-injections for the longer runs, we started on the far end, and worked our way back. As before, we laid the tracks out, and where necessary, attached a power injection using [heat-shrink solderless connectors](https://amzn.to/4dHCpgZ). Soldering and then applying heat shrink isn't a terribly large deal, but doing it all in one pass is efficient, and the gel these connectors use to secure themselves around the wire adds extra waterproofking, akin to filling a heat shrink tube with hot glue or grease, and so its hard to beat.

![Tracks laid out and heat gun](/postimages/permanent_leds/track_and_heat_gun.jpg).

For the segments that were less than 1m long, such as the corners, we popped the LEDs out of the tracks, using a [little tool I 3D printed](https://makerworld.com/en/models/468510#profileId-377651), cut the tracks, and either wrapped the string of pixels around the bend, or cut it and attached a connector. More heat-shrink solder splices were involved in this process.

Finally, when all was done, we turned it on, and tested it. They are _very bright_, and you could see them in the middle of the day, at middling brightness:

![Lower level done, showing LEDs on, at decent brightness](/postimages/permanent_leds/bright.jpg)

And at night, they look amazing in both color (the first image in this post) and white:

![All pixels lit up in warm white](/postimages/permanent_leds/white.jpg)

## Closing

This was an amazingly rewarding project, and I cannot state how good they look at night. Some of my neighbors, who previously balked at the prices commercial operations have charged, are now interested in DIY. Ultimately I paid just shy of $2000 for this project, which includes all the components AND bringing out a contractor to help with some of the upper roof segments (I'm not comfortable on that tall of a ladder). Since _everything_ about the control side of this is open-source, I have it wired up into HomeAssistant, and already have some automations set up, such as automatically turning them off _around_ midnight, the ability to turn them on automatically around sunset/sunrise, and voice control ("Hey google, turn on the roof trim"). I plan to set up even more automations, such as turning them on in various team colors should they win a game in their associated sports, as well as a calendar integration, so I can schedule them to turn on at arbitrary dates, without worrying about doing it manually.

And I've already had to deal with a single puck failing, which caused all the subsequent ones to start behaving erratically. Fixing this one failed puck was rather simple; I just detached the segment with the faulty puck, took it inside, cut the bad puck out, spliced a new one in, and was up and running again in under an hour. Had I gone with strips, I couldn't have brought it inside to do that, and would have had to sit there splicing with a headlamp as my sole illumination, atop a ladder.

## Updates:

+ Linkrot ate the original link to the pixels I used, so I've updated it. The new link is https://www.aliexpress.us/item/3256807344866216.html

[xLights]: https://xlights.org/
[WLED]: https://kno.wled.ge/
[esps]: https://github.com/forkineye/ESPixelStick
[it]: https://quinled.info
[Dig-Octa]: https://quinled.info/quinled-dig-octa/
[PermaTrack]: https://permatrack.us/
