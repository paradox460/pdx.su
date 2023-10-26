---
date: 2023-10-25T18:57:41-06:00
---

# CSS is fun again

CSS has been undergoing a quiet renaissance lately. Lots of big features, that previously required an external tool to use, are now native features of the language. And its growing more and more all the time. If you haven't used CSS in a long time, for whatever reason, now is the time to take a look again.

## Brief history, and how CSS became "not-fun"

Back in the late 90s, we styled our websites using inline attributes. `bgcolor`, `font`, and friends ruled the roost. And this was okay. If you wanted a more complex style, you used tables and sliced up images. Or you just used Flash, but thats a whole different beast. When CSS came out, it was pretty cool, but far too simple to really do what we needed. You could set colors and sizes and some positional properties, but that was kind of the limit. You still had to use tables to do complex layouts. You still had to do image slicing for round corners and shadows and other silly things, but it was "better." CSS 2 rolled around and gave us some primitives for actually positioning our stuff. We could move things around the page, float them off to the side, and adjust a lot of how they looked. CSS was finally viable for doing the whole page. We ditched tables. And we quickly ran into the limits of what we could do. Rounded corners still needed image slicing. Complex positioning, i.e. grids (so complex!) required JavaScript. And for many people, this is where CSS stagnated.
CSS didn't really stagnate. It slowly marched forwards, growing things like shadows, border-radius, and then later flexbox and grids. But, despite this slow progress, it had gathered a reputation of being brittle and difficult to work with. Tricks like clearfixes arose; bits of knowledge you just had to find and use, and then apply like cheap plaster in a house you intend to flip. Reset styles arrived to make things somewhat consistent. External tools like Sass and PostCSS streamlined the process of authoring CSS, making it so you didn't have to remember all the browser prefixes or how to write all the border radiuses. And eventually, some developers just started throwing away parts of CSS, favoring simpler approaches, while not being sure exactly of what they were giving up, but certain they didn't need it.

## The quiet renaissance

As time passed, CSS slowly grew new features. Most of them were novel, but constrained in their utility. Selectors like `:is` and `:where`, while useful, only slightly moved the needle in terms of just how much code you had to write. Flexbox and CSS Grids arrived, made things easier for those who used them, but received less fanfare than they deserved; many sites and layout frameworks still use older methods, the ones the developers learned through fire trials.

Variables, or custom properties, made a big splash, particularly because they can do things that couldn't be done otherwise. Preprocessor variables are not context aware, they can't be reset using things like media styles or user preferences, and so they're basically just super-fancy find-and-replace placeholders.

But recently, the pace of new features has accelerated so much, that I envy those who are just learning CSS today, and don't have to learn all the baggage and old ways of doing things. They'll just see all the new tools at their workbenches, and get down to work.

CSS Nesting is the biggest "preprocessor" feature, with every preprocessor worth its salt implementing it, and now it's done in native CSS. There's a bit of a caveat around syntax as some last minute changes landed, but it's not quite like the prefixes of yesteryear; you just have to use an `&` in more selectors than is ideal, and as browsers mature, this limitation will likely disappear. But you can now easily scope styles to a specific element or selector, and write support for the various psuedos that are common, in a neat, clean, non-repeating way. And you can finally write your media queries _inline_, where they belong, with properties inside them, rather than the previous redundancy we saw before. Not really exciting if you've already been using a preprocessor, but now you don't need that preprocessor for _this_.

`color-mix` takes another bite out of the preprocessor pie. Instead of having to use sass functions like `lighten` or `darken` or `transparentize`, you can now just write them with real css. And since they're done in real css, they're color space aware, and can make use of custom properties too. Wanna make a highlight out of a primary color, which is picked and set externally? Piece of cake

```css
.selector {
  background: color-mix(in srgb, var(--primary-color), white 50%)
}
```

This mixes your primary color with 50% white, in the sRGB space. You can use other, newer, better color spaces too, such as OKLCH, which is my favorite.

Containment and Style queries landed, which let you make whole sections of your stylesheet that style based on _their size_, not the window's size. For component based designs, this is incredible. Now you can make components that render one way when they are "small" and another way when they're bigger.

And it's not all big new features either. Lots of things got quiet little improvements. Transform properties were broken out into separate properties, so now you can do `translate: 50%` instead of `transform: translate(50%)`. `display` was revisited, allowing now to mix and match display types, so you can more adequately specify both how something is positioned relative to its content (inline vs block) and how content inside it is positioned (flex, grid, table, etc). `display` also became animatable, so now you no longer have to figure out how to move an element between hidden, shown but not visible, and shown but visible. New trigonometric functions landed, allowing for accurate angular math.

All of these features are available _today_, as of this reading, with every major browser supporting them in the current version

## The renaissance isn't over

And more features are on the horizon, or already landing.

Colors are gaining even more superpowers, via the Relative Colors feature of the CSS Colors level 5 spec. When it lands, you don't even have to use the "new" `color-mix` feature to do common things, like hue-shift or lighten a color. You can now easily manipulate any value of a color, in any space you like, same as you would any other value.

Want to make a transparent version of a color? Piece of cake:

```css
:root {
  --primary: blue;
  --transparent-blue: hsl(from var(--primary) h s l / 50%);
}
```

How about making a lighter version of a color?

```css
:root {
  --light-blue: oklch(from blue, calc(l + 25) c h);
}
```

Instead of having to use cumbersome functions, you can just use `calc` and the same color functions as you would to define a single color.

Native CSS scoping is landing too. Using it you can now target styles to a specific scoping root, or specifically carve out holes in your styles, without having to get too funky with things like `:not`. This is a rather complex feature, so I'll [link to the Chrome blogpost about it](https://developer.chrome.com/blog/new-in-chrome-118/#css-scope)

## Closing

I've been using nesting and the color-mix features pretty heavily since I found out about them earlier this year, and they've been great. There's a bit of a learning curve, as with any new tool, but its rather short and gentle. I still keep Sass around, as well as PostCSS, for things that CSS just wont ever be able to do (nor should it), but they're fading into the background, rather than being at the forefront of my mind when writing styles.
And for small, simple projects, I don't use them at all. Just pure CSS. I haven't found it lacking.
