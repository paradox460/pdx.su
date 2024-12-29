---
date: 2024-12-29T16:00:46.012318-07:00
title: Using Kagi for a bit over a year now, here's what I think
notoc: true
---

# Using Kagi for a bit over a year now, here's what I think

I've been using the [Kagi] search engine for a bit over a year now, and while it's not fundamentally changed my life, it has made me reflect and think about some things, mainly where the internet has gone, where it was, and what we've lost along the way. It's safe to say that most of us spend most of our waking hours doing _something_ with the internet. It's in our pockets, on our wrists, in our ears, in front of our eyes, and sometimes, quaintly enough, on our computers. Yet, as many people have noticed, the internet has gotten really irritating to use over the last few years.[^1]

[^1]: Ed Zitron covered it _far better_ than I could hope to say in his article [Never Forgive Them](https://www.wheresyoured.at/never-forgive-them/)

Part of what makes it immensely irritating is that the tools we used to rely on for navigation through this wilderness, the search engines and content crawlers, have become actively hostile towards us as users. Google no longer tries to show you what you're looking for, instead it tries to show you things that it wants you to see. And what Google wants you to see is ads. Additionally, Google is under the somewhat perverse incentive _not_ to give you what you want, as the more time you spend searching, the more ads you see. Couple that with the amount of shit they shove at the top of a search result page, and it's a miserable experience.

Gone are useful tools like the older knowledge graph; it's been replaced by a cyborg facsimile, an AI box that hallucinates its own insane, twisted reality. From things like telling people to put glue on pizza to eating rocks to just flat out inventing things that don't exist.

And it's been trending downwards for a while now, seemingly gaining steam and becoming shittier as time goes on.

## Enter Kagi

Mid-2023 I started hearing some interesting things about a new search engine. Comments on HackerNews, reddit, and in some private chatrooms, were talking about a new search engine, called [Kagi]. At first, I ignored these discussions, figuring it was another flash-in-the-pan startup (remember [Cuil](https://en.wikipedia.org/wiki/Cuil?useskin=vector)?). But over the summer of 2023, the talk about this tool didn't wane, as usually happens with these things, but rather intensified.

Finally, in September, I'd repeatedly heard enough good things from enough different sources, I decided to check it out. At first, I wasn't terribly impressed. A paid search engine? Come on. Who the hell is going to pay for search? Yeah, Google isn't great, but Bing is marginally better, and Bing _pays you to use it_[^2]. But Kagi, and commenters across the internet, implored me to try it, to use the 300 free searches, and see what it was all about. If I didn't like it after the first 300, I could go back and not pay a cent.

[^2]: Bing "pays" you through Microsoft reward points, which accrue slowly but steadily. With somewhat regular usage, I was able to get Xbox Gamepass for free every month.

So I tried it. And I loved it. At first, I just treated it like another search engine. I put in my query, got back results. Boring, right? Well, yeah, boring by 2007 standards. But by 2023 standards? The results were _actually what I wanted_. And things that Google and others long since cast aside, like boolean operators? Available, in all their glory. I found myself doing something I hadn't done in nearly a decade: aimlessly browsing the web, finding new and exciting pages, written by small bloggers, authors, whatever; people who were passionate about their work, and not underwritten by some faceless content mill.

I burned through my 300 searches in about a week. The moment I hit my limit, I jumped and bought one of their ultimate plans, for a year. I have no regrets on that purchase. Looking at my usage page, I average about 950 searches a month, with some outliers being as low as 400 a month or as high as 2000 a month. And this doesn't include searches that use DDG style `!bang`s, which Kagi not only supports, but lets you add your own custom ones[^3]. Yeah, you can add custom search engines to most browsers worth their salt these days, but the bangs somehow feel more useful. Maybe It's that you can shove em at the end of a search to change what the search is doing.

[^3]: I've got custom bangs for things like HomeAssistant integrations, 3D models for printing, fish shell commands, and more. Things I look up somewhat frequently.

Over the year, my usage of Kagi changed as well. At some point, I discovered the `?` bang, which will force Kagi to generate an AI chatbot answer at the top of your search results. At first, when I read about this, I was dismissive. The Google and Bing versions of this weren't terribly useful, often providing worse than wrong answers, but I went in open-minded, and was impressed. While I don't use it all the time, It's nice to be able to search something like `When did Duke Ellington die ?` or `Is Atomic Heart on Xbox Gamepass?` and get the answer right there, complete with citations to check its work.

I still only use the AI chat feature sparingly. Kagi gives you access to most of the big models, through their own interface, which is useful when trying to research something, prototype a bit of code, or whatever else, but I still find them only about as reliable as a precocious teenager, happy to make up things to make themselves sound smarter than they actually are. I do enjoy that I have them, in a nice interface, that lets me run the same query against different models and compare the results. I do enjoy that, being run through Kagi, instead of a user account associated with me, they're effectively washed in a big stew of all the other AI queries other Kagi users are making, bringing about a thin layer of anonymity. But ultimately I don't see them as being hugely useful. A novelty, for sure, that comes in handy, but if it was turned off tomorrow I probably wouldn't miss it.

And you might be asking, in that whole year (and then some) of using Kagi, how often was it _unable_ to find what you're looking for. And the answer is a bit more complicated than it should be. Most of the time, if I couldn't find it on Kagi, it was a flaw in my search terms, that more refinement was able to sort out. Every time Kagi couldn't find something, using another search engine proved equally fruitless. Since Google and Bing are a single bang away, if something wouldn't turn up, I'd try them, but ultimately stopped doing so, as they never returned what I needed.

The two areas where Kagi is weak, and where I _do_ shell out to other engines for more information, are local (maps) and images. Google Maps is a juggernaut in the local and maps space, and is extremely hard to dethrone. I like that Kagi lets me use Apple Maps and OpenStreetMap[^4], and give it a good college try every time I need to find something and have a bit of time to suss through the results and find what I want. But if I need something _now_, like closing times for a restaurant, I just immediately append the `!gm` bang to search in Google Maps.

[^4]: This isn't really Kagi, Apple, or OpenStreetMap's fault. I really respect what each organization is trying to do, notably the latter most. OSM is an amazing project, and I've contributed a small number of edits and waypoints to it, but the task is absurdly huge, and Google has a massive first-mover advantage in the space.

Image search in Kagi is _good_, but not great. Image search seems to be rather tricky to conduct properly, as _no engine_ gets it right entirely. Depending on context, I typically find myself using Bing image search or Yandex Image search. Google Images _used_ to be good, but ever since Google got a bug up their ass about content in their search results, it's been rather useless.[^i]

[^i]: I'm hoping that computer vision and the other associated "AI" technologies can really make image search better, but unfortunately what seems to be happening is that instead of finding the image that is what you want, they're just going to generate an ugly, shitty knockoff of said image, and tell you that there were always 5 lights.

And that leads to what was ultimately the most revealing revelation about Kagi, and how it changed how I search the web. Google is _all too happy_ to color their results to align with their particular corporate biases. If you are in agreement with the bland "safe" Bay Area values that Google's corporate structure holds, you probably won't notice this, but the moment you step out of line, on any subject, you'll suddenly find that Google won't show you what you're looking for. Inconvenient facts are buried in a manner that Orwell would dismiss as too heavy handed to be believable. Search results and suggestions will serve to nudge you back onto the "safe" path, and when that nudging fails, just refuse to show you what you're asking, instead just vomiting out SEO garbage or counterpoints that align with the Google values.

Kagi doesn't do that. If you search for disgusting content, and turn off safe search, you get what you ask for. It treats you like the adult using the product that you are, not like some petulant child asking inconvenient questions. And once you get used to the freedom of _having a search engine respect your wishes_, returning to the same old is an exercise in frustration.

---

Anyway, that's my pro-Kagi rant for the end of the year. If you haven't tried it, I'd encourage you to try it. Kagi doesn't do affiliates or referrals, so I gain nothing either way, but I want to see them succeed, so they can stay in business and keep making the best search engine I've used in the last decade.

[Kagi]: https://kagi.com/
