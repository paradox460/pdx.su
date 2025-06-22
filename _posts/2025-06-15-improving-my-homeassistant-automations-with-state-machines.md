---
date: 2025-06-15T01:13:44.991121-06:00
title: Improving my HomeAssistant Automations with State Machines
---

# Improving my HomeAssistant Automations with State Machines

A little over a year ago, [I migrated the bulk of my HomeAssistant automations from NodeRED to DigitalAlchemy](/blog/2024-06-09-migrating-my-homeassistant-automations-from-nodered-to-digital-alchemy/), a TypeScript based automation system. Since then, I've slowly been adding more and more automations, of varying complexity. For simple ones, the built in event-based system works well enough, but as soon as you start having to track state across a few different entites, it becomes a big, unwieldly mess.

## State Machines?

This is a problem encountered in a lot of other domains, and the solution is often to use what is known as a finite state machine. Finite State machines are a whole topic on their own, with plenty of ink spilled, so I will only skim the surface, but essentially they let you model a real world system as a series of states and transitions. States are things like "on", "off", "open", "closed", etc. Transitions are the "in-betweens". "turn on" would be a transition from "off" to "on", for example.

In the Elixir/Erlang world, a _lot_ of things are modeled as state machines. GenServer, which a lot of people consider the building block of most Elixir/Erlang applications, is a kind of state machine. While it lacks the formalities that let you rigidly define transitions and states, the primitives are all there. There's even an erlang module called [gen_statem](https://erlang.org/doc/man/gen_statem.html) which allows you to very easily build full fledged state machines.

Since DigitalAlchemy is typescript based, I can't use `gen_statem`, but there are a number of decent Javascript statemachine libraries out there. I settled on [xstate](https://xstate.js.org), which is rather mature, and ties into the [stately.ai](https://stately.ai) platform, which has both a robust VSCode extension, and a decent web interface (more on this later)

## Basic XState usage

XState is rather simple, once you get the hang of it. You define a state machine, and then create an actor from said state machine. The actor is an instance of the state machine. You can have multiple instances of the same state machine.

You trigger states by sending events to the actors. Depending on the current state, the events can trigger transitions, or do nothing at all. You can attach actions to transitions, as well as to entering/exiting a state. Using this, you can program in desired behavior, limiting potential states, and ignoring undefined behavior. For something like HomeAssistant, that means you don't have to explicitly code around "undefined" and other states that you don't care about.

## Using XState in DigitalAlchemy

DigitalAlchemy doesn't really do anything out of the ordinary that would prevent you from using XState. In most cases, you just install it to your project, import it, write your state machine, and its off to the races.

### Mailbox monitor

Recently, I built a simple mailbox notifier, using ESPHome. My mailbox has a top door and a bottom door, and I monitored both using reed switches. The mail carrier will always use the top door, as its the "incoming" mail, and I'll always use the bottom door to retrieve the mail, as its the locking mail bin.

Since the monitor is running on battery power, I used the deep sleep functionality of ESPHome. This means that the device is off most of the time. Since it takes a little bit of time to wake up and connect to HomeAssistant, there is a chance it misses a trigger. If the mail door is opened and closed before we can connect up to HomeAssistant, HomeAssistant will see the door as "closed", and we won't know which door triggered. Since ESPHome has no concept of "store and forward" for events, we have to handle this in a round-about way. We add two additional binary sensors[^1], one for each door, that listen to the main door sensors, and if they see them go true, they themselves go tru, and then _hold_ that state until the next shutdown, which triggers at the end of the wakeup period. That way we can trigger off either the main door, or the "sticky" sensors. If you want to see the ESPHome YAML for the mailbox, its [available on my github](https://github.com/paradox460/HomeAssistantConfig/blob/main/esphome/mailbox-4559ac.yaml)

[^1]: We could have encoded both into a single sensor, using tricks like bitmasks, but it doesn't really cost anything extra to add another sensor, and the logic is much simpler to follow.

Over on the HomeAssistant side, we get a nice little device that has 4 entities we need to track:

- `binary_sensor.mailbox_top_door`: the main top door sensor
- `binary_sensor.mailbox_bottom_door`: the main bottom door sensor
- `binary_sensor.mailbox_top_door_sticky`: the sticky top door sensor
- `binary_sensor.mailbox_bottom_door_sticky`: the sticky bottom door sensor

We will also create a couple entities on the HomeAssistant side, to light up an icon on our dashboard indicating new mail, and to reset the state of our system, should something go wrong. We'll call one `binary_sensor.new_mail`, and the other `button.mailbox_reset`.

We can now actually createa a fairly simple state machine, _in home assistant_, without using DigitalAlchemy or xState, just by listening to the sensors above and using the `binary_sensor.new_mail` as our state tracker. For this case, it will work about the same. But we're going to use DigitalAlchemy and xState anyways, because for more complex cases, you can't just rely on a single state tracker, and it can get ugly quickly.

If we model the states of our mailbox monitor as a flow chart, we get something like this:

![Our Mailbox State Machine](</postimages/2025-06-15-improving-my-homeassistant-automations-with-state-machines/CleanShot 2025-06-14 at 23.47.48@2x.png>)

We can see that the only way to get to `New Mail` is from the `Top Door Opened` event, and we can get from `New Mail` to `No Mail` from either the `Bottom door opened` event or the `Reset Button Pressed` event. Pressing the reset button, or opening the bottom door, while we are in a no-mail state does nothing, and so we don't have to deal with it. Our state machine will just ignore the event as an invalid transition

One of the coolest features of xState is that you can actually build your code using a flowchart. You can use the [online editor](https://stately.ai), or the [VSCode plugin](https://marketplace.visualstudio.com/items?itemName=statelyai.stately-vscode). I use the VSCode plugin, which is pictured in the above screenshot

On Each state, we encode some _actions_ in the `entry`. Entry lets you say "Any time this state becomes active, do this". For `New Mail`, we use Entry actions to send us notifications and to turn on our dashboard indicator. For `No Mail`, we use it to clear the notifications and turn our indicator off.

The final State Machine code looks like this:

```ts
const machine = setup({
  types: {
    context: {} as {},
    events: {} as
      | { type: "Top Door Opened" }
      | { type: "Bottom Door Opened" }
      | { type: "Reset" },
  },
  actions: {
    notify: () => {
      notifier();
    },
    clearNotify: () => {
      clearNotifier();
    },
    indicatorOn: () => {
      new_mail.is_on = true;
    },
    indicatorOff: () => {
      new_mail.is_on = false;
    },
  },
}).createMachine({
  context: {},
  id: "Mailbox",
  // initial: new_mail.is_on ? "New Mail" : "No Mail",
  initial: "No Mail",
  states: {
    "No Mail": {
      on: {
        "Top Door Opened": {
          target: "New Mail",
        },
      },
      entry: [{ type: "clearNotify" }, { type: "indicatorOff" }],
    },
    "New Mail": {
      on: {
        "Bottom Door Opened": {
          target: "No Mail",
        },
        Reset: {
          target: "No Mail",
        },
      },
      entry: [{ type: "notify" }, { type: "indicatorOn" }],
    },
  },
});
```

In the `actions` block, we make a few calls to some functions we created for handling notifications, as well as setting some properties on DigitalAlchemy proxies. To tie our state machine into our actual monitor, we just need a bit of glue code, that takes state changes from HomeAssistant and uses them to trigger events on our state machine, which will trigger transitions.

```ts
const topDoorAction = ({ state: newState }) => {
  if (newState == "on") {
    mailboxActor.send({ type: "Top Door Opened" });
  }
};

top_door.onUpdate(topDoorAction);
top_door_sticky.onUpdate(topDoorAction);

const bottomDoorAction = ({ state: newState }) => {
  if (newState == "on") {
    mailboxActor.send({ type: "Bottom Door Opened" });
  }
};

bottom_door.onUpdate(bottomDoorAction);
bottom_door_sticky.onUpdate(bottomDoorAction);

reset_mail.onUpdate(() => {
  mailboxActor.send({ type: "Reset" });
});
```

We create two anonymous functions, `topDoorAction` and `bottomDoorAction`, and then use them in the `onUpdate` handler for the 4 entities that can trigger events in our system. We also use a similar pattern for the reset button. Each handler function just calls our `mailboxActor` and sends it an event, which our above state machine definition defined. The state machine listens to those events, and if they can trigger a transition, they do, and we call the appropriate actions.

The full, working code example of the mailbox is [here](https://github.com/paradox460/HomeAssistantConfig/blob/main/home_automation/src/mailbox.mts), and the previous, non-state-machine driven version is [here](https://github.com/paradox460/HomeAssistantConfig/blob/1221833326b58d03bc48a7211c6f631793dc8dbb/home_automation/src/mailbox.mts)

### 3D Printer Automation

My 3D Printer is connected to a smart switch, which I use to turn off power to the printer when it's not in use. This is a mix of a safety precaution and a bit of energy saving. It's a safety precaution to prevent the printer from doing things without my initating them, and an energy saving meeasure to prevent the device from drawing power while idle. I want to have the switch turn the printer off after a few hours of inactivity. We can define inactivity as any time the printer is not printing or running a filament dryer.

Modeling our state machine in xState, we get something like this:

![3D printer state machine diagram](</postimages/2025-06-15-improving-my-homeassistant-automations-with-state-machines/CleanShot 2025-06-15 at 01.02.11@2x.png>)

It's a lot more complicated than the Mailbox monitor, but can be broken down into a few main "things"

- The printer is idle when it is not printing or drying
- The printer can be both printing and drying at the same time
- Printing has multiple sub states that should be considered "active"
- Drying has only one state that should be considered active, "drying"
- Both printing and drying can be "idle"
- We want to have an initial state that is unsynced, where we don't actually know the state of the printer
- At any time, we can transition to `power_off`, because the real world has things like power failures or users hitting the e-stop button
- `power_off` can only transition to `idle`, because the printer has to boot up before it can resume a power outage print, or anything else

Key things to call out in this state machine are the use of actions on transitions, guard clauses, "after" transitions, and parallel state machines.

Actions on transitions let us perform something whenever a particular transition is triggered, and _only_ when that transition is triggered. On the `startPrinting` transition, we reset an energy meter, so I can see how much power the current print has used. Similarly, on the transitions out of the `printing` state, we typically fire off notification handlers. Note that we are not using any entry/exit actions in this state machine, they simply don't suit our needs here.

Guard clauses are used to check the status of both child state machines (`printing` and `drying`) on the `active` state machine. We have this guard clause set in what's known as an `always` transition, a transition that will fire on _every_ single other transition involving the `active` state machine, which is all of the transitions of its children, and transitions on itself. The guard clause prevents it from firing when some condition isn't met. In this case, we have the guard clause set to check if both the `printing` and `drying` state machines are `idle`. If so, we can transition back to our parent machine's `idle` state.

"After" transitions let us fire a transition if a state machine has been in a particular state for a duration of time. We use it here to shut down our 3D printer's smart plug if we've been in the `idle` state for a few hours. If we transition out of the idle state at all, for any reason, then the timer is cancelled, and will start from the top next time we enter the idle state. This transition has an explicit action tied to it, which turns off our smart plug. This is the only time the state machine will turn off the smart plug

Finally, there's a top-level transition, which always listens for a `turnOff` event. Should our smart switch be turned off at any time, for any reason, we can transition our state machine to `power_off`, and have it match reality.

Before I moved this to a state machine, I had a fairly complicated bit of code to track the status of a 3D printer. Whenever the printer was idle, and the smart plug was on, I would start a timer. When the timer finished running, it would check the state of the 3D printer, and if it was in a "good" state (not printing, not drying), it would turn off. If I started a print job or a drying job, the timer would be cancelled, to be resumed later. This was rather fragile, as "printing" is a whole progression of states of the printer, and handling the corner cases, such as what happens when a print/dry job finishes while a longer print/dry job is still running, became maddening. There was also some speical logic around drying, as that gives us an end time, but it never really worked all that well.

You can see the full [state machine and associated digital-alchemy code on github](https://github.com/paradox460/HomeAssistantConfig/blob/main/home_automation/src/bambu.mts), and [what it looked like before](https://github.com/paradox460/HomeAssistantConfig/blob/c63072a792fe7a228e64999be65ae76326fafda3/home_automation/src/bambu.mts).

## That looks an awful lot like NodeRED

Kind of! Flowchart based programming can be useful, particularly for things like state machines, but I still find it much easier to reason about this than NodeRED. NodeRED had some weird constructs, that I just haven't had to work around in this. Since there's always "real code" right there, I never felt as constrained as I did in NodeRED, where I'd frequently just toss a Javascript action in there to get something done when I couldn't figure it out.
