---
date: "2023-02-13T22:18:18-07:00"
permalink: "/blog/:year-:month-:day-updating-my-fish-theme"
image:
  src: "https://pdx.su/postimages/fish-theme.png"
---

# Updating my Fish Shell prompt and Theme

I've been using Fish Shell for nearly a decade now, and over that time I've gradually developed a theme and prompt that I enjoyed. At the start of this year, I rewrote it from the ground up, eliminating many years of accumulated cruft.

![screenshot of the theme](/postimages/fish-theme.png)

<md-note icon='️🖼'>

My theme is available at https://github.com/paradox460/paradox-theme

</md-note>

## The beginning

Around the new year, the Fish team released a new update, 3.6, that brought with it many new features, and some breaking changes. Historically, when a new version of the shell has been released, I've updated my prompt/theme to accommodate the new changes, but rarely made significant changes to how the underlying prompt was built. This time, I had a few days off, so I decided that it was a good time to do some cleaning, removing old features, rewriting new ones to use fish builtins, and adding support to features that Fish has grown since the theme was first created. I still wanted the theme to be roughly the same as before, but faster, leaner, and more predictably stable.

## Goals

Looking at my existing theme, there were some things I wanted to keep:

+ Command separators
+ Right-prompt timestamps
+ Git/VCS lines
+ A display of the current git hash in the prompt
+ Ability to support variable color themes

There were also some things that just didn't ever work right, worked but weren't ever of any use, or just were irrelevant with the ongoing changes to fish:

+ Current command execution time
+ Current ruby version

## Initial rewrite
Years ago, when I wrote the first version of my theme, it was mostly a "port" of a theme I'd previously used on Zsh. The old zsh theme is lost to time, but when I initially ported it to fish, certain features the current fish shell has did not exist. The command separators were created using the unix `jot` command, with some math to calculate the width needed to print the separator. The first version of the separator didn't have a command status, and was a fixed color, but upon seeing a shell theme from a former coworker, he had short (5 hyphens) separators between commands, colored depending on the exit status of the previous command. I liked that _a lot_, and so for my theme (at the time, zsh based), I copied it. Later, I added a section, using box drawing characters, to display non-zero exit codes.

In the time since that theme was written and ported to fish, fish has gained the [string repeat](https://fishshell.com/docs/current/cmds/string.html#repeat-subcommand) command. This command takes a string and number, and repeats the string the number of times. Simple. And exactly what I wanted. Fish also gained a new feature, called pipestatus. Pipestatus is similar to the plain ol' status variable, except it's a fish list (an array) of exit codes, one for each pipe. Useful. Implementing the printing of these in a style that fit my theme was fairly easy. Other sub-commands of the `string` command were used, and gave me a satisfactory output.

The rest of the prompt was pretty easy to make. Fish gives you a lot of useful little primitives for printing a prompt, such as a truncated `pwd`, utilities for displaying user and host name (I don't use either, I find them useless noise), and a very good VCS prompt. The VCS prompt has the ability to show you the current branch, ref, or sha, but getting it to display both a ref and a sha is still impossible. This is trivial enough to wrap in a small function, and so I did.

The right hand side of the prompt is even more trivial. Fish gives you a function to print rprompt, so I just overrode this function and made it print the date.

Finally, I hard-coded some color support into the theme. In my older version of the theme, I was using one of the [base16-shell][] color scripts, but found they have a non-trivial runtime impact, and don't play nicely with older curses apps. Fish supports expressing colors in hex, and, provided your terminal emulator supports it, will directly print components of its "ui" in the colors you specify. You can set these via variables, most prefixed `fish_color`. This is all fairly well documented, and if you didn't want to do it in a theme file, you can do it via Fish's web configuration interface.

## Evolving the color scheme support

Many modern terminal emulators support use of codes to set colors in the terminal. Not colors over certain areas, but rather, the _terminal colors themselves_. Things like the background, what the older color values are painted as, and so forth. I primarily use iTerm2, which has its own set of escape codes to set colors, and I wanted my theme to ensure that it was rendering the way I intended, so I added support for these color codes.

While doing this, I hacked in some primitive support for [base16-shell][] themes. This was partially because I have a friend, who has expressed interest in my theme, who is unable to use dark mode due to his astigmatism. By adding a "hook"[^hook], I added support for grabbing the colors out of a theme file, and using them appropriately in the fish UI.

This wasn't the best approach, because both the [base16-shell][] and my theme would attempt to set terminal colors (at least in iTerm2). So as a hack I tossed in a check for either a theme-specific variable, or the presence of a base16-shell set envar, and if found, disable the theme shell color setting.

### Light/Dark mode

This was mostly satisfactory, until I got the bright idea to add automatic day-night theme support. Apple exposes the current color scheme to any application that asks for it via a `defaults` property, so by running `defaults read -g AppleInterfaceStyle` you can determine if the user is using a light or dark mode. Thinking that supporting two different color schemes would be trivial, I added a set of light colors, and a check to toggle between the two. This turned out to be a rabbit hole that I spent more time on than the writing of everything up to this point.
First, reading the value doesn't always return a value. If the user is on light mode, then you get _nothing_ back. Normalizing this value wasn't hard, but it was another thing I just had to figure out, as documentation was sparse.
Second, I felt that, for non-mac users, there should be a way for them to set their color scheme preferences.
Finally, for users of a specific color scheme from base16-shell, I added a check that just bypasses all the light/dark logic.

Gradually, other features grew into this functionality. None of it is terribly exciting, mostly just trial and error, so I've summarized it:

+ Checking the system color scheme at prompt init time gives you a colored prompt, _and never checks again_. This means that if you change your scheme, you'll get a shell that is dark or light, and sticks out. I added a configuration to check the system color changes with _every_ prompt (defaulted to off)
+ Users may want to manually trigger a color refresh, such as if they've manually loaded colors or changed variables. Exposing internal functions as external ones allows for this, in a convenient way
+ Some shells will still fudge color rendering, for things like bold colors. This is true, even if you set the extended color table values (more on that in a moment). There's nothing you can do about it, other than instruct your users.
+ Programs using older versions of ncurses will break your 256 and true-color themes. Short of the program fixing its dependency, all you can do is reset the colors on program exit. There's no universal way to do this, so for the few apps I use that do it (tig), I just aliased their commands to a function that calls the program, and then calls the color scheme refresh command on exit.

### Extended colors and other terminals

Some programs have support for "extended colors." This lets you specify additional colors over the older 16 colors, which can enhance TUIs. The [base16-shell][] project has long set these colors, but the code I'd added to my prompt _didn't_. I thought I didn't care about this feature too much, but seeing the colors absent from certain programs was jarring. Fixing it was trivial enough, one just has to find the extra colors that can be set, and set them. I was only targeting iTerm2, and so this was a piece of cake.

But what about other terminals? One of my friends uses Linux, and the theme consistently didn't render as well as I'd have hoped on their terminal. And, from time to time, I'll open a terminal in VSCode, which doesn't support the iTerm2 color codes either, and so my prompt would render funky there as well. Fixing this wasn't the most trivial thing, but it wasn't exciting either. Mostly trial and error, again. Along the way I had a few false starts, with mistakes about how to encode the colors (hex pairs, 0-255 pairs, etc.), how to properly send the escape codes, and so forth. Documentation on this is _atrocious_. I had to consult several older websites, wikipedia, and then engage in a lot of testing in `kitty.app` to get the output I wanted.

During this iteration, I also "matured" some features. I genericized some terms (they previously referenced only iTerm2), optimized some code paths, and fixed up the readme (which I wrote using [asciidoc](/blog/2023-02-05-asciidoc-and-markdown)). The theme is now "stable", and I've not had to make any changes since. If you do choose to use it, and find something wrong with it, please open an issue, and we can figure it out.

[base16-shell]: https://github.com/tinted-theming/base16-shell

[^hook]: Mostly just a check to see if the `$BASE16_SHELL_ENABLE_VARS` variable was set, and then reading the color values into my internal color variables.
