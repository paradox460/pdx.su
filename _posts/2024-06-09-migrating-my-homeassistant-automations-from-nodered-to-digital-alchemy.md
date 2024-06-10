---
date: 2024-06-09T21:24:13.0-06:00
---

# Migrating my HomeAssistant automations from NodeRED to Digital-Alchemy

For my home automation needs, I use HomeAssistant. And for more complex automations, I used to use [NodeRED][nr]. Recently I undertook some effort to move over to [DigitalAlchemy][da], which lets you write automations in Typescript. Here's what I learned in the process.

## Home Automations via HomeAssistant

The platform I use for most of my home automation things is [HomeAssistant][ha]. It's a powerful platform, and will probably show up in other blogposts in the future. HomeAssistant is great because it lets me integrate many services into a single automation framework. It's easy to extend, and serves my needs well. I moved over to it from HomeSeer a few years ago, and the migration has been for the better in almost all regards.

Out of the box, HomeAssistant has a fairly powerful automation system built in. It is comparable to that of HomeSeer, or more widely known systems such as Tasker on Android and Shortcuts on iOS. Essentially, you have a collection of triggers, conditions, and steps for your automation.

For example, if you wanted to turn on a light every time the sun came up, you can do that fairly easily. You'd set a trigger that listens for a state change in the `sun` integration, and when the trigger sees that `sun` has changed to `up`, you'd fire your automation to turn on the light.

You can do far more complicated automations with the built-in system, although it tends to get somewhat unwieldly. Automations are, at the core, a set of discrete steps that flow one into the next. You can add parallelism with some useful constructs, but they very much adopt a trigger-condition-action structure, and breaking out of this becomes confusing quickly.

## Enter NodeRED

Many people in the HA community make use of an excellent package called [NodeRED][nr]. NodeRED aims to make more powerful and complex automations far easier. It works through a flowchart paradigm. You drag out blocks that represent either triggers, actions, or primitive control logic, and literally "wire" them together, via lines in the UI, to do what you want. Automations that are hopelessly complex in pure HomeAssistant become simpler in NodeRED.

However, it isn't without its flaws. The developers and community around NodeRED seem averse to introducing too many "programmer-y" constructs. There are no primitive boolean gates, if/else objects, or simple comparators. You _can_ do all these things, but it isn't immediately obvious, particularly if you come from a programming background.

Additionally, there aren't many ways to "dry" up a NodeRED flow. Say you have many similar, but ultimately different, flows. In programming, you'd just make a common function that handles what it can, and use it where appropriate. You can try to make a sub-flow, but this is limited, and often winds up being more complicated than just copy+pasting nodes everywhere.

Variables are kind of a mess; each flow can have its own, and there are global variables as well. They work well enough, but they're not really surfaced too much by the UI, and so if you don't remember (or leave a note) where a variable comes from or goes, it is largely opaque.

Finally, NodeRED flows are difficult to store in a version management system. They're not generally human-readable when serialized out to JSON, and ultimately insignificant edits to the "shape" of a flow can result in massive diffs.

## DigitalAlchemy Cometh

For a few years now, I've shrugged my shoulders and accepted that NodeRED was the best we could get. There are other script-based automation platforms based around Python, but I really don't care for python, and so don't want to use it for my HomeAutomation if I can avoid it.

Earlier this year, a developer named Zoe released [DigitalAlchemy][da], which strives to be a powerful automation framework for HomeAssistant, centered around use of TypeScript for its automation.

I don't mind JavaScript and its friends. It's not my favorite languate family, not by a long shot, but its not repellent to me either. For something like home automation, it's event oriented system, easy async, and friendlyness to functional programming paradigms make it an obvious choice.

DigitalAlchemy is a wonderful little framework, that uses many of the features TypeScript exposes to give you a very powerful way of writing and maintaining automations. It generates TypeScript types for _all_ of your HomeAssistant integrations, so when you're editing your scripts, you get both code completion, but also sanity checks. No more trying to pass a fan to the Light: Turn On service.

And since its _real_ TypeScript, you can use _real_ JavaScript techniques when programming. Want to use a powerful state machine to handle your automations? You can do that, trivially. Just include one of the ones you find on npm, write the glue code, and away you go.

Over the course of a month, I ported all of my automations out of NodeRED and into DigitalAlchemy. The process was rather straightforwards, and the resultant automations are _far_ simpler than their predecessor. I can open one up in VSCode and immediately start working, without having to remember too many weird quirks about how the system works. Feedback is fast, and so iteration times are equally fast. There's even a repl for testing ideas out on the fly.

And the lead developer, Zoe, has been spectacularly responsive. Questions and suggestions get met with near-immediate fixes or implementations, sometimes multiple iterations within the hour of first being brought up. They've recently been working on some tremendous improvements to the DigitalAlchemy synapse system, which lets you create and expose virtual entities in HomeAssistant _from_ your DigitalAlchemy scripts, allowing a more two-way flow of control for scripts. It's really quite powerful; I've used it in several of my scripts to provide "circuit breakers," so I can do things like turn off the smart-away automations when I've got guests over.

### Use SyncThing to make editing far more enjoyable

If you are running Digital Alchemy through the HomeAssistant platform (quickstart), you might get tired of editing your automations in the browser based VSCode interface. While you can use systems like SMB or SSHFS to mount your HomeAssistant filesystem for editing, this does impose a performance penalty.

Instead, I suggest using the [SyncThing][st] addon for HomeAssistant, and setting up a sync between your development machine and your HomeAssistant install. You can then edit and build your automations locally, and just restart the DA addon in HomeAssistant when you're ready to run them.

## Addendum

If you're interested in seeing _how_ DigitalAlchemy scripts look in practice, I encourage you to check out [my implementations](https://github.com/paradox460/HomeAssistantConfig/tree/main/typescript).

[ha]: https://www.home-assistant.io
[nr]: https://community.home-assistant.io/t/home-assistant-community-add-on-node-red/55023
[da]: https://docs.digital-alchemy.app
[st]: https://github.com/Poeschl/Hassio-Addons/tree/main/syncthing
