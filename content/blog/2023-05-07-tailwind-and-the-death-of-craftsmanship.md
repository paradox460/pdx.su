---
date: 2023-05-07T21:52:18-06:00
---

# Tailwind, HTMX, and the death of web craftsmanship
There's a worrying trend in modern web development, where developers are throwing away decades of carefully wrought for a little bit of perceived convenience. Tools such as Tailwind CSS and HTMX seem to be spreading like wildfire, with very few people ever willing to acknowledge the regression they bring to our field. And I'm getting tired of it

## History

Back in the 90s and early 00s, if you built a website, you probably didn't style it very much. If you did, you used tables, some attributes on the various HTML tags you had, and a lot of images. Changing anything required you to update every single occurence of that _thing_ within the HTML. There were attempts to work around these defects; people would build templating systems in Perl and other languages, but fundamentally, you were putting colors, dimensions, and such _into_ your HTML.
This was awful, and when CSS came out, even as limited as CSS 1.0 was, people eagerly adopted it. CSS+tables, some image slicing in Fireworks or Photoshop, and you could build a pretty good looking website. CSS 2 came out a few years later and dramatically improved things, allowing far better layouts to be achieved.
In the middle of the 00s, Firefox and then Apple began pushing standards forwards, introducing many new features. Border-radiuses, gradients, box shadows, enhanced fonts, flexbox, grids, and many other layout tools. It was a veritable CSS renaissance. Pre-processor languages, such as Sass and Less, sprouted up, bringing useful bits of programming to CSS, and tools like Autoprefixer later cropped up, reducing the overhead of cross-browser support to almost nothing. Tools matured, and we entered a period where building web apps was more fun than it had ever been.

### The Cracks start showing.
As we entered the twilight of this CSS renaissance, some of the issues CSS has began to show up more and more frequently. Wrangling large CSS files became more and more tedious, deeply scoped selectors began causing issues, and component-based development patterns began to push people towards building "website legos," self-contained units, apart from their CSS styles.
There were attempts to tame the CSS beast. BEM, OOCSS, SMACSS, and friends pitched themselves as the "one true" solution. They all basically have something in common: they tell you to get rid of various CSS features to "simplify" things.
Out of this rose Tailwind. Instead of writing your CSS, you just used a bunch of different utility classes to style things.

##
