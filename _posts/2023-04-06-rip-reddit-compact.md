---
date: "2023-04-06T10:00:00-06:00"
permalink: "/blog/:year-0:month-0:day-rip-reddit-compact"
---

# Rest in Peace, Reddit Compact

Reddit has recently disabled/removed access to the compact interface, which was useful on mobile and low power devices. As my first professional project _ever_, I'd like to reflect on it, 13 years the wiser.

## Origins

Back in 2009, I had a Blackberry Storm. It wasn't a great device, but it was neat for the time. The screen was "big," it looked pretty, and it could browse the web, albeit poorly. The built-in browser was mostly optimized for WAP style sites, a few steps below the then amazing browsers on the iPhone and Android devices. There was also the Opera browser, which was much better at rendering pages, but used server-side rendering, meaning _no javascript support at all_. Because of these limitations, browsing reddit on a Blackberry, even a big touchscreen one like the Storm, was almost exclusively a read-only experience. You could choose between the then-WAP styled, read-only reddit mobile site, which looked a lot like HackerNews does now, amusingly, or the "full" desktop experience, which kind of worked without JS, but not well. I was mostly okay with this, as I could blame it on the lack of decent browsers on the Blackberry.
Christmas 2009, I received a Motorola Droid, known as a Milestone outside the US. This was a substantial upgrade over the Blackberry. It had a physical keyboard, a better touch screen, ran Android, and, importantly for this post, a Webkit based browser. Suddenly the read-only reddit seemed like a much bigger hindrance than it did before. You could post and browse the full desktop site, but it was suboptimal (seriously, try browsing https://old.reddit.com on your phone). I wasn't impressed by what I saw in terms of mobile interfaces; I can't remember if Reddit is Fun (now RiF for Reddit) was one of the apps I tried, but if it was, 18-year-old me wasn't impressed. And so I set out to make my own mobile interface.

## The early steps of the mobile interface

This was right smack-dab in the sekuomorphic interface era, and there was plenty of iPhone style interfaces for "studying" across the internet, mostly in screenshots. Reddit had its own in-house iPhone app, called iReddit, but nothing for Android. Being a web developer primarily, I started out making a simple interface on top of reddit. My javascript skills at the time were quite lacking, so I was handling most of the API stuff with glued together bits of Perl and PHP, rendering it on the server. This wasn't terribly unusual for the time, the era of jQuery, Ext.JS, and Google Web Toolkit. The interface was lightly styled, mostly using webkit based CSS features, lots of background gradients, and so forth, but it looked a lot like the final compact interface looked.

## Becoming an official reddit interface

January 2010, I was in the #reddit IRC channel on freenode, and some reddit admins were active one night. I showed keysersosa some screenshots of the reddit interface, and he seemed fairly interested in it. Extended conversations turned into an invitation to make it an official reddit project. I was given some access to a staging instance of reddit, ssh access to said instance, and some instructions on how reddit's internals worked. Chris, aka keysersosa, and the other reddit admins, were tremendously helpful, and put up with a lot of my naïve and immature questions and approaches. Over the next several months, the mobile interface took shape. Towards June, it had become fairly feature-complete, with voting, submitting, commenting, sign-ups, and most other core reddit features. Some interfaces never really got built explicitly for mobile, but they still worked reasonably well, since the mobile layout was fairly flexible to render content. Several people helped with the QA, catching bugs I had no hope to ever figure out.

![v1 of reddit mobile, as seen on a TechCrunch article](/postimages/reddit-mobile-tc.jpg)

Come June 9th, [we launched it](https://web.archive.org/web/20100612133310/http://blog.reddit.com/2010/06/better-mobile-reddit-for-all.html), and got a [nice article in TechCrunch about it](https://techcrunch.com/2010/06/09/reddit-mobile).

[I wrote an old blog post](https://web.archive.org/web/20100614000623/http://paradoxdgn.com/post/the-design-process-for-reddit-mobile); for whatever reason Archive.org didn't preserve my sites styles, but you can read and see some great images, regardless of CSS. You can see the android 2.0 style pop-overs for post and comment options in that article.

[You can view the old reddit comment thread](https://www.reddit.com/r/announcements/comments/cd9ju/weve_revamped_reddits_mobile_site_let_us_know/) here.

## Becoming a contractor/employee for reddit

With the success of reddit, and my need for cash as I went off to University, I asked if I could become gainfully employed by reddit. Surprisingly, they said yes, and I was able to join reddit's team and become an admin. This was incredible for 18-19 year old me, as I was able to get a good jump-start on my career.

Over the next year, I worked on a variety of reddit "things," from a revamp of the advertisers dashboard, several side-banner ads for certain campaigns, a large resolution banner we used for the Rally to Restore Sanity reddit booth, some UX tweaks and changes for the fresh reddit gold, and more.

## Improving Reddit Mobile

One thing that some people noticed about that first version is that it could be quite resource intensive to render on first loads, and had weird performance issues. Additionally, certain systems were completely inaccessible from mobile, bouncing you out to the desktop interface.

Most of the slowness was traced to the massive amounts of CSS gradients and effects used. Every post, button, and more, used gradients, shadows, and more. They would often be repainted for _each_ button, which was costly on phones of the time (the Nexus One was considered speedy, with its 1GHz CPU).

This was fixed by rendering a small image of the button styles, and then slicing the image up, 9-patch style, with CSS border images. This gave us buttons that could be any dimensions, with nice looking backgrounds. Other gradients were also flattened into background images, such as those of the header toolbars.

The post options pop-overs were kind of a sticking point as well, with some people complaining about their usability. We replaced them with inline expandos, that spanned the width of the browser, and had much bigger touch targets.

Finally, we added a mail and modmail link to the upper right, replacing the old double-chevron menu, and removed the `Home` button in the upper left, instead rendering the subreddit logo image and subreddit title.

These features launched, and had a [small blog post celebrating them.](https://web.archive.org/web/20110724041754/http://blog.reddit.com/2011/07/next-generation-of-reddit-mobile.html), with a [corresponding reddit comment section](https://www.reddit.com/r/blog/comments/iw1kz/the_next_generation_of_reddit_mobile/)

## Leaving reddit

During 2011, reddit was undergoing a lot of significant changes. They split off from Condé Nast, becoming their own company, and underwent some organizational restructuring. Almost the entire staff, who worked there when I joined, had moved onto other things, and there was an effort to consolidate power and access to the San Francisco office. Finally, my school-work was starting to take more of my time up, and so I was unable to seriously focus on reddit and school at the same time. So it was time to move on. Some features that I had intended to add to the compact version, that never materialized, were mobile moderation, better sharing (this would take nearly a decade for browser-induced share intents to arrive), web-worker/service worker backed notifications, and many more things. Many of them materialized in the "new" reddit interface

## The end of compact

For the last couple of months, there have been comments on the [/r/compact](https://www.reddit.com/r/compact) subreddit about issues rising up with the interface. Commenting, posting, voting and other features would sporadically stop working. A few weeks ago, adding `i.` as a prefix, or `.compact`, to reddit URLs, stopped rendering the interface. A workaround was to use `https://old.reddit.com/whatever.compact` instead, but that was patched last week.

There's been an outpouring of disappointed comments in the compact subreddit, which is touching to see, and several people have started working on userscripts, alternative interfaces, and so forth, to try and resurrect compact.

When people are asked why they like compact, typically they will say something along the lines of how performant it is. Which is not surprising, because it was built targeting a device with a 533MHz CPU and 512Mb of ram. JS was minimal, mostly jQuery style, and the CSS optimizations we made in 2011 _still_ hold up.

## Looking back, 13 years later

13 years wiser, with nearly 10 years of full-time software engineering experience, I can't but help look back at where I got started from. I am extremely grateful to the people that helped me along the path, Chris, Mike, David, Eric, Jeremy, and many others. Without them, I surely wouldn't be the software engineer I am today. Without the opportunity to "jump right in," I might not have even become a software engineer. I really appreciated the professionality I was afforded, as someone so green, was awesome. And getting to go to DC for the Rally to Restore Sanity is still one of the high points of my freshman year of college.

The comments I've gotten over the years, and the recent outpouring of support for the interface, a decade later, is incredible. Knowing that people love and continue to use the interface I built, and are going out of their way to resurrect it when it was End-of-Life'd by reddit, is awesome.

So, Thank you old reddit admins, users, and everyone else who helped me along the path.

[comments on reddit](https://www.reddit.com/r/programming/comments/12dpmq6/rest_in_peace_reddit_compact/) [comments on hackernews](https://news.ycombinator.com/item?id=35470777)
