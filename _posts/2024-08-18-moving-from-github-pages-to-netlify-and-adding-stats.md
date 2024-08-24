---
date: 2024-08-18T12:36:19.631911-06:00
---

# Moving from GitHub Pages to Netlify, and adding some statistics

When building this site, one thing I wanted to do was do it as cheaply and easily as possible. I didn't want to have to go out of my way to write for it, deploy it, update it, or anything else. And I certainly didn't want to pay for it. As such, I built it in a very particular way.

The site is built using the [tableau static site generator][tableau], by Mitch Hanberg, and the _entire site_ is [open source][gh]. Assets are handled using [ESbuild], and consist mostly of some CSS niceties, and the occasional javascript component written in [lit]. Posts are written in markdown [^1], in VSCode, and deployments are simply done as part of a CI/CD process; I push a blogpost up, and the blog updates.

[^1]: I have plans on moving my writing language over to [djot]. I've written a [djot package for elixir][xdjot], and so just need to patch [tableau] to allow for different formats in the default page and post generator

## The past

Initially, the site was [built using vuejs, but I migrated over to tableau](/blog/2023-11-14-migrating-to-tableau-ssg/). The details as to why I did the migration are in the linked blogpost, but suffice to say all these months later I don't regret the migration to tableau.

GitHub pages were a natural fit for what I was trying to do. They're free, easy to use, support basically anything that can generate plain HTML, support and automate HTTPS, and more or less just work. You miss out on some fancier features, but at the time I didn't really need those (more on that later).

Deploying to ghp in an automated fashion was rather simple. Just use GitHub actions, and the built-in deploy to GitHub pages action, and you're good to go. You can see how I used to do it [here](https://github.com/paradox460/pdx.su/blob/117a0c6fd35f160a5ec0a9702555d952078669c9/.github/workflows/ssg.yml). This workflow builds the elixir site, builds the assets, minifies the HTML files, and deploys them to GitHub pages. Simple, easy to reason about, and free.

## Analytics

For a long time, I didn't really care about how much traffic my site got. Sure, I wanted to have people read it, but I didn't really care how much read it, or where they came from. I've got a search keyword monitor for links back to my site, and so would see when various things were published to various discussion forums and other blogrolls, and where appropriate I'd join the conversation. But recently, I had a [post](/blog/2024-03-17-reading-my-electric-meter-with-rtlsdr/) get a decent amount of attention, being featured on sites like [Hackaday], and suddenly I found I wanted to know where my visitor traffic was coming from.

I'm generally wary of most analytics systems. They're a nasty part of the surveillance reality we all live in, and most of them are horribly intrusive when it comes to privacy. They're also essential parts of web advertising, and so they want to track where a user goes _across the web_. I use a handful of systems to block as many trackers as is reasonable, and so was hesitant to add any to my personal site, as it felt a bit hypocritical.

Over the past few years, I'd been hearing good things about [plausible analytics][plausible]. I first heard about them through an elixir based discussion, although I can't remember which. They're an open-source analytics platform, that you can run _entirely yourself_, as well as a hosted option that, while not free, is well within affordable. They have a strong focus on privacy, so much so that they use _no persistent tracking mechanisms at all_.

If I were hosting my site on a more traditional webserver, like Nginx or Apache, I could analyze the logs to generate site data. Back in the days of Drupal, Joomla, and e107, I did this a lot for my pet sites, and its honestly astonishing how much information you can get just by scanning the logs and comparing them to something like the Maxmind database. Since I'm not, I don't get that data for free. But using something like plausible seems a good compromise.

And so this site now uses plausible for its analytics. You can view the analytics the site collects (probably rather unimpressive) at any time [here](https://plausible.io/pdx.su/), which is also available in the footer of every page. There is _still_ no persistent tracking mechanisms on this site, and you can double-check that (no cookies, no localstorage, nada).

## Adblock

One of the problems with _any_ third party analytics script is that some popular blocklists take a stance that _no tracking at all is permissible_. This is fine, and it's the right of users to decide what connections their computer does and doesn't make, but it throws a wrench into the works when trying to get something that resembles accurate analytics, even if they're non-invasive, particularly for more technically oriented sites like this one. [Plausible themselves estimate that on techincal sites, up to 60% of viewers may block their tracker.](https://plausible.io/blog/google-analytics-adblockers-missing-data) Not great for me.

The simplest way around this is to proxy the analytics script through a server you control. Great idea, but I don't control my server. GitHub does. And GitHub pages offer _nothing_ when it comes to things like this, which is fair, as GitHub pages is more or less just serving up HTML and related assets.

The lazy thing to do was to just stick with GitHub pages, and accept that only 40% or so of my viewers would be accounted for in my analytics. That's fine, but I was feeling motivated, so I started investigating my options, and very quickly settled on Netlify.

## Netlify

[Netlify] is one of a handful of companies that have cropped up to cater to the "new" web, where sites are built using technologies like JAMstack, and served as more-or-less static assets, with very lightweight server computational requirements, if any. Essentially, they work like most other static site serving services (i.e. GitHub pages), but offer a few extra features. One such feature was configurable proxies and rewrites 👐. This is exactly what I needed for more accurate analytics.

Setting up an account with them was, expectedly, pretty simple. Click a few buttons, fill out a form, and you've got an account, ready to deploy some sites. And that's where things get complicated.

I initially tried to deploy the site using their automatic GitHub linking, and the first build failed almost immediately. Looking through the logs of the build/deploy, It's pretty clear as to why. Their builder saw that I've got a `package.json` in the root of my site[^2].

[^2]: This particular `package.json` is _not_ where I define the assets my site uses, those live in one under the `assets` directory. Instead, it simply exists to _force_ yarn to run through a corepack version, so VSCode and other editors don't try and use npm.

Digging into their builder a bit more, it quickly proved to be unsuitable for what I needed. Doing builds that involve differing languages, such as nodejs and elixir, are possible, but tricky, and from what I could find, poorly documented. Doing builds that use modern versions of Elixir and Erlang were even more difficult; they are running 1.9 for Elixir, which came out in 2019, and so would require me to figure out a way to install newer versions on their build system.

Ultimately, I wound up keeping the build system I was using for GitHub pages, but instead of pushing to GitHub pages, pushing to Netlify instead.

[The build script itself](https://github.com/paradox460/pdx.su/blob/3ee2b1a7e603911d084dd9d520d5798ed821d70f/.github/workflows/ssg.yml) is rather straightforwards. The assets and the elixir site are built separately, to get a performance boost through parallelism, and both make use of the [upload-artifact] action to store their generated outputs. Then another job, dependent on both previous builds, downloads these assets using [download-artifact], merges them together, runs minification, installs the Netlify cli, and deploys.

Simple.

Moving to Netlify also netted me a few other positives. Overall global performance has improved, slightly, although one of my friends in India reported that their latency went up a bit, as Netlify no longer has any servers there. And I can now finally modernize a bit of how images are served. Previously, all the images in the site were served verbatim, as they appeared in the source, which usually meant as a Jpeg. Now, thanks to Netlify, images are compressed a bit better, and served depending on what the user's platform supports, be it avif, or webp. Maybe in the future we can serve JpegXL.

[tableau]: https://github.com/elixir-tools/tableau
[gh]: https://github.com/paradox460/pdx.su
[xdjot]: https://github.com/paradox460/djot
[plausible]: https://plausible.io/
[upload-artifact]: https://github.com/actions/upload-artifact
[download-artifact]: https://github.com/actions/download-artifact
