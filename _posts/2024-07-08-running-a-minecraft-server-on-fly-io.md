---
date: 2024-07-08T13:37:07.147923-06:00
permalink: "/blog/:year-:month-:day-running-a-minecraft-server-on-fly-io"
---

# Running a minecraft server on fly.io

Running a minecraft server can quickly become an expensive endeavor. Even a small server needs a reasonably powerful machine to run on, and with the landscape of hosting providers, that can quickly rack up in costs. Ideally, we'd run a server when we want to play, and not when we don't, minimizing the amount of useless time we pay for. And Fly.io makes it possible to do _just that_.

## Fly.io

Fly.io is my favorite of the "new" cloud companies. They let you quickly spin up and down virtual machines to do what you want, have a _great_ networking stack, and aren't the most expensive. I use them a _lot_ for little applications, as well as some of my professional endeavors on Elixir. They've kind of moved into the hole that Heroku left when they went fully corporate.

One of the particularly nice features of Fly is that you can make a server automatically start and stop, depending on traffic. So you can have a minecraft server that boots up when you want to play, shuts down when you don't, and is still publicly accessible.

## Complications of running on Fly

Running a minecraft server on a more traditional VPS, like DigitalOcean, is fairly straightforwards. You just boot up the machine, shell into it, install minecraft, and configure things. This is great for how easy it is to get started, but its a very manual, interactive process. You have to do everything by hand, and then rely on the persistence (storage volume) to maintain your changes across reboots, with the general assumption that your virtual private server will always exist [^1]

With Fly, or any other similar hosting provider, you _don't_ have that same persistence. _Every single boot of your Minecraft server will be "different"_. Sure, when you mount a volume, which you need to do for world and other persistent data, it comes along for the ride, and you _can_ fake a persistent style manual setup. But you shouldn't have to. If you can extract all the configuration out to a file, or set of files, that can be applied to the server at boot, your server becomes more resillient; instead of having to remember how you edited what file when, you just have it in your configuration. This is the same philosophy behind systems like [Nix](https://nixos.org)

Other complications arise when we want to tell Fly _how_ to run our server. The easiest way to get arbitrary binaries up on Fly is by providing a docker image. We could build our own Docker image, that contains a minecraft server and some other stuff, but that's a whole endeavor of its own, one that we might not wish to undertake. Fortunately, there's an absolutely excellent docker image for running minecraft servers already.

## Enter docker-minecraft-server

[docker-minecraft-server](https://docker-minecraft-server.readthedocs.io/en/latest/) is an amazing docker setup for running a minecraft server. It's got a ton of features, including automatic plugin installation, config patching, auto-stop, and more. It's perfect for what we want to do.

Getting it installed is rather straight forwards, and the docs are excellent, but I've made [a repository that reflects the way I got it set up.](https://github.com/paradox460/minecraft-dedi-server)


### My changes

If you looked through my repository, you might notice that I make my own docker container, based off the one created by itzg. Minecraft still requires a bit of manual finagling, and so I wanted to make the ecosystem within my server's deployments more pleasurable to ssh into. So I add a few utilities to the base image, set up my config patches, so they can be versioned with the git repo, and tweak a few other system settings. Most of the changes are simple things that just fit _my_ workflow better; you probably don't need them and can run the pure itzg container.

## Building my fly.toml dynamically

To deploy on Fly.io, you use a configuration file called `fly.toml`. This file contains almost all the information your server needs to run, barring a few things like secrets.

The trouble with writing a `fly.toml` by hand is that certain niceties are absent, notably when dealing with environment variables.

docker-minecraft-server makes use of envars to configure many aspects of how it runs and boots, including where and which plugins it downloads and installs. You specify these as either a newline or comma separated list of URLs or other references, which are picked up at boot, installed, and synchronized. TOML allows for multiline strings, so configuring the list of plugins isn't terribly difficult, however more dynamic lists, such as the `SPIGET_RESOURCES` variable, which points to resources hosted on Spigot plugin repos, are cumbersome to use.

Specifically, `SPIGET_RESOURCES` wants a comma-separated list of id numbers, and _nothing else_. And spigot resource urls are rather descriptive, but the id number is not. I wanted a solution that would let me use the "full" spigot urls, but take advantage of the spiget downloader feature, which manages version updates for me.

Finally, I wanted to make use of fly's PROXY_PROTOCOL support. PROXY_PROTOCOL allows passing of proxy information to servers and other applications, and is relevant to our usecase here because, if turned off, all incoming connections to our minecraft server won't resolve as their "real" IP, but rather a fly internal IP. But I wanted to be able to turn this off and on, and it requires configuration in a few places to do so.

Aiming to solve all these problems, I wrote a [simple little deno script](https://github.com/paradox460/minecraft-dedi-server/blob/f8646c983d9264c16b7dfd5f9f76f72ed1015a63/fly.ts). This script is fairly simple, and mostly just does some string concatenation, but it _does_ let me do things that the plain old TOML wouldn't.

I can set a single value, enableProxy, and have it set up both the fly port setup AND the envar, which is used by a patch to enable the proxy support on paper, and by docker-minecraft-server, to enable the auto-stop system to monitor our server.

I can also take full spigot URLs, strip the non-numeric-id portions, and render them out to a format that the docker container is happy to use.

I don't make use of this feature, but since this is _just_ a script file, I could also move the configuration to be generated in a much more composable manner, or to use local .env files, or any number of things.

Since I used deno, we also get the advantage of the script being "self contained". By using a custom shebang, I've made my script executable, so to build a new toml file you just have to run `./fly.ts`. No need to install packages (other than Deno), no need to remember which runner to use.

## Deploying, and things to note

Once the new fly.toml is generated, deployment and running the server is an absolute breeze.

`./fly.ts && fly deploy` gets the server up and running, and I can connect to it in Minecraft, as expected. All the plugins and configuration I've specified in config files have been loaded onto the server, and any appropriate config patches have been applied.

Manual configuration, as always with Minecraft, takes a long time, but isn't tremendously difficult, just tedious. Things like LuckPerms, WorldEdit, WorldGuard, and your "basic" plugin of choice (I use [CMI](https://www.zrips.net/cmi/)) need to be configured, same as always. You can do these configurations in a variety of ways; adding them as custom `COPY` commands to the Dockerfile, using docker-minecraft-server's [patching](https://docker-minecraft-server.readthedocs.io/en/latest/configuration/interpolating/#patching-existing-files) system, or just by shelling into the server (via `fly ssh console`) and editing them by hand.

If you use premium plugins, you won't be able to automatically download them, as they likely require authentication to download. You can make use of the [/plugins attach point](https://docker-minecraft-server.readthedocs.io/en/latest/mods-and-plugins/#optional-plugins-mods-and-config-attach-points) to load these plugins into your docker container, at which point the minecraft scripts will pick them up and put them in the right place.

The server makes use of a few values that shouldn't be exposed in your plaintext config, but rather set as "secrets". Fly has a feature for this, where you simply set them via a command

```bash
fly secrets set RCON_PASSWORD=$(openssl rand -base64 32)
```

This will be exposed as an envar in the container, which handles all the RCON stuff for you, and works nicely

### AutoStarting, and why I didn't set it up

One of the more powerful things about this config is that you can make use of both autostart and autostop.

Autostop is handled by the minecraft server container; it monitors connections to minecraft, and kills the process after a configured duration, causing the Fly vm to shut down. This is "safe", and is what I'm using. It lets you quit the game and not rack up a big bill because you forgot to quit the server. When configured with powerful enough anti-afk features in Minecraft itself, you can prevent issues where a player causes the server to be up endlessly through negligence.

However, AutoStart is a more complicated beast. AutoStart exists as a part of _fly's_ systems, not as something that's minecraft aware. It works fine with minecraft, but has one very large caveat: _any TCP traffic on your server's exposed port(s) will boot the server_. If you're trying to save money, this isn't great, because it means a random server scraper, a nefarious script, or even someone just letting the minecraft server listing sit open, will keep booting your server again and again and again.

Because of this, I elected to manually start my servers, and let autostop handle the rest. Starting is trivial enough, simply run `fly apps restart` and your server boots almost immediately.

If you run your servers _entirely_ on a private network, then this isn't so much of an issue, as you have less risk of bad actors. However, you _still_ have risk, as negligence on behalf of one of your players could keep the server alive for a very costly period of time.


[^1]: I'm purposely ignoring things like actual physical machine migrations, etc, because they're largely irrelevant when running something like a minecraft server.
