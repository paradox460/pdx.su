---
date: 2023-02-05T17:39:53-07:00
updated: 2023-02-06T13:49:47-07:00
---

# I wish Asciidoc was more popular

I've been using Markdown for a long time, and have grown accustomed to it. It has various quirks, features, and oddities, but what doesn't. But recently I decided to take a look at Asciidoc, a Markdown "competetor". I found it a great little document toolchain, but it won't replace Markdown.

Both Asciidoc and Markdown allow you to write text based content using a simplified markup syntax. Instead of heavier syntaxes, such as LaTeX, HTML, and friends, or rich-text formats that require WYSIWYG, both allow you to focus on the writing, and add formatting with simple, plain-text friendly characters. And, for most use cases, you won't really see the difference between Markdown and Asciidoc. 90% of the time, it won't make a difference in how you write, save maybe using a different character to format something some way. But the remaining 10% is where empires are built, and in this area Asciidoc is far superior.

## Markdown++

Asciidoc will happily accept Markdown, verbatim. You can take a Markdown snippet, paste it into your Asciidoc file, and it will (generally) work. But ad has so much more to offer, and so many little better ways of doing something, that you'll soon wish Markdown worked similarly.

For example, Markdown has a syntax for inserting a break, inside a paragraph. You put two space characters at the _end_ of a line, and the parser will inject a line break. Unfortunately, spaces are a "weird" character. They're not visible, unless you turn on the "show invisibles" equivalent in your editor, and even with that enabled, it can be difficult to see them while scanning a document. Also, many editors will remove trailing spaces, causing your break to disappear. You can typically configure them to _not_ do this to a Markdown document, but its another thing you have to remember, hope the developer of the editor remembered, or set up a plugin to do for you.

You don't want to make newlines significant, like GitHub does on its issues and some other sites have done, because then you lose a great feature of Markdown (and most other markup languages): the ability to format and fit content in your editor, loosely independent of how it would be presented to the user. If you've got your editor set up to hard-wrap at 80 cols, for example, you want those lines to be joined together in the output, as the width of output content is a stylistic concern. Copying and pasting a hard-wrapped snippet of text into GitHub usually requires you to join the lines together, using an editor feature (like `J` in vim) if you're lucky, and by hand if you're not.

Asciidoc fixes this elegantly. Instead of making trailing spaces indicative of a significant break, they make a trailing `+` character indicate the break. This solves basically every single problem the Markdown implementation has. You can visually scan for the `+` at the end of a line, you can have syntax formatting that makes it significant, and, going the other way, you _don't_ need special editor features to show you its presence.

And this style of minor improvements persists almost everywhere else throughout Asciidoc. The formats it chooses for its primitives are _better_ than Markdown, in almost all cases. I'm not a huge fan of how it approaches links (you put the URL _before_ the link's text), but it's not any stranger than HTML.

You get a lot more formatting tools out of the box, including super and subscripts admonitions, easy video and audio embeds, automatic references, tables, and more. And where features are common across both Asciidoc and Markdown, the Asciidoc implementation is typically better, such as how they handle nested and ordered lists. Markdown list depth is usually a game of wrangling with indents and newlines, to get your particular parser to pick up and agree to how they work. Asciidoc uses a repeated list delimiter approach, where you just repeat the delimiter to indicate depth:

```asciidoc
* item 1
** sublist
*** sub-sublist
* item 2
```

Ordered lists are better too. Instead of having to either manually number them yourself, or just use `1.` as the indicator, you just use a `.` character:

```asciidoc
. item 1
. item 2
. item 3
```

You can also adjust where the list starts, and any skips, via attributes.

Other list types exist too, such as definition lists, questions and answers, and checklists.

Asciidoc also has first class support for "admonitions". Admonitions are basically a specifically formatted block of text, designed to draw the readers eye, and call out something that might be relevant to the surrounding text, but is ultimately not part of it.

::note
This is an admonition!
::

If you've ever read the O'Reilly programming books, you should be familiar with these little things, they're used liberally.

## Attributes and blocks give it superpowers

One of the most powerful features of Asciidoc is the attributes and blocks system. Asciidoc documents are structured in blocks, which are arbitrary length collections of lines. Lines can be text, attributes, directives, or formatting instructions.

You can arbitrarily create a block using some delimiters, and then use directives and attributes to change things about that block. Admonitions, which I mentioned earlier, are just one example of a special block type. There are also attributes that affect lists, code blocks, blockquotes, tables, images, and even just simple ones for adding a CSS class to a paragraph.

There are inline attributes that let you have access to more powerful text formatting, such as attributes for underlining text, inserting a `kbd` formatting style to indicate keystrokes, and more.

## Includes, macros, and references save you time

Includes, macros, and references are all things that can simplify document creation, particularly in the case of technical writing and documentation, where you have lots of repeated content, content that could be better written in its own source file, and cross-links.

Includes are what they sound like, the ability to have all or a portion of another document injected into the current one. If you've ever used latex, and have a "master" document that includes all the other documents in your project, you'll understand how nice it is. You can split up thoughts into chapters or logical sections, with file-system level distinctions, and then arrange them however you want without having to cut and paste large amounts of text.

Macros are great for repeated urls, acronyms, and disclaimers. You can define them once, and just use a shortcut syntax to reference them anywhere.

Finally, the references syntax Asciidoc uses is far superior to the de-facto reference syntax Markdown has adopted. Markdown cross-references are a function of the output, typically being HTML, and require your output tool to generate memorable, but unique, IDs on your headers, so you can link to them like `[some reference](#some-reference)`. There's generally no easy way to know what the reference will be ahead of time, and no way to customize or override it.

In Asciidoc? References are first class, and have special features. All Asciidoc implementations use the same rules for a reference, so its easy enough to predict what it is. References are inserted using a special syntax, compared to links, which makes them visually distinct while editing. And references, by default, insert the contents of the _header that defined them_ at the reference site. You can override it, both at the reference site, _or the default at the header_. In one document, I had a very long header title, that was referenced frequently. I set its reference tag to a short 3 letter abbreviation, and the injected text to be a slightly longer abbreviation.

## Extensibility

Asciidoc is inherently extensible. Since the document structure is very well-defined and described, writing extensions that hook into any part of the processing isn't difficult. You can add your own custom blocks, admonitions, or anything else. You can implement your own handlers for things such as video tags, so you can reference a YouTube video as simply as writing `video::4QdWRgNdir4[youtube]`

## The downsides

After reading all that, you might be wondering if there's anything bad about Asciidoc? I've waxed positive about it for nearly 8000 characters, but in fairness we should discuss some of the things that _aren't so good about it_.

First off, it's a _single_ implementation.[^1] This is both a blessing and a curse. The blessing is that you only ever have to worry about how your document will be parsed _once_. The curse is that you have to be happy with whatever the main Asciidoc developers decide, or write your own extensions. If your extensions get too far out of sync with the main standard, you kind of run into the problem Markdown faces, where you're basically a language that looks and kind of reads the same, but is ultimately incompatible.

Single implementation also limits its utility for other systems. If you're maintaining a service, like StackOverflow, Reddit, or GitHub, and you want to parse Asciidoc content for your users, doing so can be more complicated than it would be with Markdown. I wouldn't be surprised if there's a Markdown parser in every programming language ever written, but I would be surprised if you can find more than a handful of Asciidoc processors. The Asciidoc website lists 3 official ones, a ruby one, a javascript one (transpiled from ruby), and a java one. There's no C implementation, no rust one, none of that. So if you want to get Asciidoc support in Elixir, you have to either write your own, hope someone else wrote one, or come up with some way to shim one of the official ones into your application (NIF, port, dedicated service).

With Markdown, if you wanted to parse user content, and you were worried about the parsing being a bottleneck, you had a wide variety of options to choose from. You could just send the raw MD over the wire, and let a client-side piece of JS do the formatting (to be fair, you can do this with Asciidoc too). Or you could reach for some speed-optimized Markdown processing toolchain, implement it on your server, and go about your day. Over a decade ago, reddit moved between Markdown parsers a few times, from a python one, to discount, to a variant of [sundown](https://github.com/reddit/snudown). I suspect other sites that parse a large amount of Markdown content, such as StackOverflow or GitHub, have done similar things.

GitHub _does_ support Asciidoc, and their support is very good, but it runs in Asciidoc _safe mode_, which disables some of the more interesting features such as includes. Additionally, you have to do some special trickery to get admonition icons working right.

## Markdown is still king

Markdown has inertia, and that's one hell of a thing. Its almost ubiquitous at this point. There are editor plugins, there are services for it, there are universal conversion tools that convert to and from Markdown. Many languages even have _multiple_, competing Markdown implementations.

Markdown is (loosely) universal. You can take something written using primitive Markdown (not any specific implementation's features, but the core described by Gruber or Commonmark) and use it on a huge variety of sites and services.

Markdown is fairly extensible, within reason. While the true extensibility of Markdown depends on your processing toolchain, how hard you want to work, and what you're willing to do, it is ultimately still extensible. Asciidoc extensions are more standardized and easier to reason about, but there are simply _more_ Markdown extensions and implementations out there.

You can even use quasi-standards like MDC/MDX to bring Vue/React components _into_ Markdown, giving you a massive amount of power, in a very easy to use package.

::note{color=cyan}
The admonitions on this blog, for example, are an MDC component.
::

Want GitHub-style Markdown? Go for it, GitHub has even [published a standard for GFM](https://github.github.com/gfm/). Want your own? No problem, Slack and Telegram have both done it.

If you want to build documentation sites, static sites, dynamic sites, use a CMS, use a form, whatever, chances are there's extensive Markdown support for what you want to do.

I looked into using Asciidoc for my blog. I got really excited to do so, but then ran out of steam almost immediately. There's just no real extensive support for it, so anything I was going to do, I'd be blazing my own trail. While those kinds of projects are often really enjoyable and educational, I just wanted to get the blog online, so I deferred.

I'll still likely keep using Asciidoc for certain types of documentation sites, although with limited support in Elixir's HexDoc, I'm not sure how often I'll be able to.

## Addendum

In the [Hacker News](https://news.ycombinator.com/item?id=34680558#34683736) discussion on this post, `zh3` pointed out that, on many systems, an installation of Asciidoctor is frequently rather heavy. This, as pointed out by `yrro`, is because it tries to ship with support for db-LaTeX, which allows for the generation of LaTeX (and therefore PDF) files via Docbook. On systems that use Apt for package management, one can _just_ get Asciidoctor, and none of the latex support, by running

```
apt install asciidoc asciidoc-dblatex-
```

You can also just install the bare minimum package by running apt with `--no-install-recommends`

[^1]: Many commenters on hackernews and reddit have pointed out that while its true that Asciidoctor is a single implementation, Asciidoctor itself is a reimplementation of the original, python2 implementation of asciidoc. There is a python3 continuation of asciidoc, but the "official" one is Asciidoctor. But they are all attempting to adhere to the same standard, the same flavor, unlike Markdown.
