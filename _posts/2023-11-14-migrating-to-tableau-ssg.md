---
date: ~N[2023-11-14T19:05:04.013200-07:00]
---

# Migrating to Tableau SSG

Recently I moved this site off of the older Nuxt/Nuxt-content based static site generator to [Tableau](https://github.com/elixir-tools/tableau), an Elixir based SSG. Between not really ever being fully comfortable with how "magical" Nuxt content was, and some recent changes broke some aspects I was using. This migration has been fairly enjoyable, and I was able to contribute some of my changes back to Tableau.

## Previously, on pdx.su…

Previously, I was using [Nuxt](nuxt.com/) and [Nuxt-Content](https://content.nuxt.com). This was a fairly enjoyable stack, for the most part. I could write posts in Markdown, add my own custom components to be used within Markdown documents, and publishing was relatively straightforwards.

But it was often a black box. I could tweak some things about it, most of its layout and even the way some components in its output rendered, but things such as some head tags, and particular aspects of inline code, were always off-limits. Nuxt was very nice for quickly getting a site up and running, but I never really felt that I was in complete control over how it built itself. Its output was nice and fast, and the site rendered rather quickly, but given I was using no server-side rendering, and only using pre-generated HTML output, the server-side JS features ultimately proved more of a headache than a utility.

Getting the opengraph header meta tags to render properly for each post was a bit more difficult than it should have been, and I ultimately didn't get _all_ the tags I should have.

But the biggest source of pain for me was code blocks. This is, nominally, a technical blog. I write about code a lot. And so having code blocks that look good is _vital_. Nuxt-Content uses a neat system where it processes Markdown code blocks, and lets you customize the output renderer by defining your own vue components. This is how I added things like a copy button, and some other nice decorations.

Unfortunately, those custom components don't extend to the actual syntax highlighting. When I initially made this site at the beginning of 2023, it used the Shiki syntax highlighting library. This library is pretty good, supports a decent amount of languages, and has a nice "css-variables" theme that lets you customize the output via CSS variables. I used this feature to enable use of the Base16 tomorrow syntax theme, and have light and dark mode versions.

But recently they moved over to a different fork of that highlighter, called Shikiji. This fork has some real improvements, such as actual light/dark support. However, it doesn't support the css-variables theme. It also doesn't ship with the tomorrow theme variants, and attempting to manually add them caused issues. I opened an issue against Nuxt-content regarding the problem, so hopefully it will be fixed in the future.

## Contributing to Tableau

I've been loosely aware of an Elixir based static site generator, called Tableau. Developed by Mitch Hanberg and part of the elixir-tools project, it seemed like a pretty good solution. I know Elixir, it's the primary language I code in these days. Mitch is a pretty great guy as well, and his code is always clear and easy to read. So it seemed like a natural fit for what I was trying to do.

At the time I was looking, Tableau was somewhat "incomplete," from my perspective. It was capable of doing all the nominal things it should do, and was being actively dogfooded, as it was what powered the elixir-tools site. But it was lacking a number of the niceities that other, older SSGs already have. It required a fair amount of "stuff" to be in the frontmatter of _every_ post, that could be abstracted away to either defaults or somewhat "smart" generation at compile time.

The best way to get an open-source project to meet your needs is to directly contribute the code that enables it to do so yourself. And so that is what I did. I forked the repo, and added a variety of the features I wanted, over a few weeks, and opened pull requests for them. Mitch gave feedback where needed, tweaked the code to match the style he likes for Tablea, and ultimately merged in my changes. Not my first open-source contribution, not by a long shot, but it always feels good when that happens.

With the improvements to the post (and pages) systems in place, I contributed a sitemap feature, and got down to business, porting my site over.

## Porting my site

With this current incarnation of my site (there are some older ones lost to time, and I don't care to revisit them), I generally kept things pretty simple. Most of my content would be in posts, and posts would largely exist "alone." A reader who was interested could scan all that I'd written, but I wouldn't use annoying antipatterns to try and coerce them into it.

Most of the focus was on the prose, how easy it was to read. There were some clever amenities I wanted to keep; the table of contents on desktop, "smart" timestamps that show the user's local formatting and zone, and some enhanced markdown features MDC offered in Nuxt, but none of those were really blockers that would prevent me from doing what I needed.

Starting from the basics, setting up a new project to use Tableau was rather easy. Set up the Elixir project via `mix new`, add the dependencies, and write the configuration file. Writing the root template, and then descendent templates of post and page, was rather trivial. If you've ever written code for Rails or Phoenix, you would feel right at home. Compared to some "magic" other SSGs I've tried, it was refreshing to just have to do it yourself.

### Temple templates

Tableau lets you use whatever templating language you want; I could have used Slime, an Elixir Slimlang port, that I've used in the past, but Mitch also has his own templating language, called [Temple](https://github.com/mhanberg/temple), which I wanted to experiment with. Temple characterizes itself by _being_ nothing but "real" Elixir code. You write temple templates like this:

```elixir
temple do
  div id: "some_id", class: "foo" do
    "This is temple code"
  end
  if @some_assigns do
    img src: "image.jpg", alt: "an image"
  end
end
```

That's it. There are no oddities around switching to or from control logic, no funky characters to control inline whitespace, and ultimately no new syntax needed.

And temple also supports components, similar to Phoenix LiveView, Surface, or your choice of JS framework (react, vue, lit, etc.). You just define a component as a function, and call it via the `c` macro, from within a `temple do…end` block.

This let me quickly throw together all the "static" parts of the site that I needed.

### Table of Contents

For the ToC, I found the best way to generate it was to parse the generated markdown, extract the headings, and store them in an attribute. Then on each Post render, I could just pull the value, loop over it, and render it as needed.

I created a Tableau extension to handle this, that runs after the Markdown documents have been parsed and compiled, and outputs the appropriate data of the headers. Parsing was done using [Floki](https://github.com/philss/floki), and was quite easy to do.

The final bit of enhancements around the ToC were pretty easy to port over from my older Vue based site, in Javascript. I register a simple IntersectionObserver, which keeps track of which headers are visible within the viewport, and updates elements within the ToC accordingly.

A last bit of CSS was used to make the targeted header flash a few times when navigated to. Previously I used JS to hook into the Vue router and detect these changes, but doing it in pure CSS feels elegant.

### Timestamps and Notes

For the timestamps and note component, I didn't want to toss Vue into the page again, but still wanted them to be somewhat interactive. The timestamp component can _only_ be done with some client-side Javascript, as there is no server, and all pages are static. The markdown notes could have been parsed and rendered on the server side, by a Markdown pre-processor, but it was still a fun exercise to do them as client-side components.

Ultimately, I went with [lit components](https://lit.dev). Lit components provide a nice little library atop HTML custom elements, which have pretty excellent support across the board. Registering a component is simple enough, and using it is even simpler. The API lit provides is nicely similar to both react and vue, so anyone who is familiar with them should be able to pick it up rather quickly. And its heavy use of typescript decorators make it rather simple to write.

For the in-text notes, I didn't bother with adding a `noscript` equivalent. If you don't have JS enabled, sorry, they just won't render. You won't see anything broken, but they'll just be absent.

For timestamps, this was not an acceptable compromise. So I wrapped the timestamp calls in a Temple component, rendered server side, that outputs the custom element and a noscript wrapped `<time>` tag. If you have JS turned off, you'll see a date in US formatting. If you have JS on, the timestamps will be rendered according to what your browser says is appropriate for your current location and locale.

### Assets

Tableau uses an approach similar to how Phoenix handles custom asset processors: it just lets you call out to them during the `development` phase, and that's it. It isn't aware of anything special regarding CSS, JS, TypeScript, and doesn't need to be.

Because of this, my asset processing pipeline is fairly boring and regular TypeScript and SCSS, built using esbuild. Tableau starts up the esbuild watcher, which compiles files on changes, emits them to the output directory, which then triggers Tableau's file watchers to send a refresh event to the browser.

For production, I just call the esbuild build script as part of my GitHub Action.

Keeping assets and code separate may feel a bit antiquated, but it's ultimately rather simple, and with modern CSS features such as scoping, nesting, and customizable cascade layers, all the pain points from the past are pretty much absent.

## It's all open source

The previous "build" of this site was in a private GitHub repository, mostly because I wasn't the happiest with the quality of the code. But since there are comparably fewer Tableau sites to Nuxt sites, I felt that having this one be open-source would be a nice way for people interested in Tableau to see how some things work.

So you can check out my site, or view the source of a post, at <https://github.com/paradox460/pdx.su>.
