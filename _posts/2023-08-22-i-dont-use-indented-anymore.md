---
date: ~N[2023-08-22T16:54:47-06:00]
permalink: "/blog/2023-08-22-i-dont-use-indented-anymore"
---

# Why I (generally) don't use indented syntax templates anymore

Sass, Pug, Haml, Slim, Stylus, and their friends all aim to make writing various bits of your frontend easier. And they mostly deliver on this primary promise. But they are all victims to the vagaries of open software development, and seem to have mostly fallen by the wayside. I loved using these through my career, so its with a bit of sadness that I realized I don't want to use them for new projects.

## What they set out to do (and usually achieve)

All these indented syntaxes, [haml][], [slim][], and [pug][] mainly, aim to reduce the amount of boilerplate needed when writing HTML, and [Sass][] and [Stylus][] aim to do this with CSS. They are typically poised as an alternative to a built-in or already popular template language in their respective web development ecosystems, most of which typically are just HTML or CSS but with a special syntax for escaping to "real" code. With CSS the improvement is negligible, but with HTML its significant, as HTML likes to make you repeat yourself a lot.

Take the following simple HTML document:

```html
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Document</title>
</head>

<body>
  <header>
    <h1>Header</h1>
  </header>
  <nav>
    <ul>
      <li>Link</li>
      <li>Link</li>
      <li>Link</li>
      <li>Link</li>
      <li>Link</li>
    </ul>
  </nav>
  <article>
    <h2>Article</h2>
    <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quae blanditiis voluptas amet eligendi nemo libero corrupti accusamus minima laboriosam iure, quia modi nulla. Accusamus, excepturi! Voluptate dignissimos repudiandae minima facere.</p>
  </article>
</body>

</html>
```

Kind of long? You can write it in [pug][] a lot faster:

```pug
html(lang="en")
  head
    meta(charset="UTF-8")
    meta(name="viewport" content="width=device-width, initial-scale=1.0")
    title Document
  body
    header
      h1 Header
    nav
      ul
        li Link
        li Link
        li Link
        li Link
        li Link
    article
      h2 Article
      p Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quae blanditiis voluptas amet eligendi nemo libero corrupti accusamus minima laboriosam iure, quia modi nulla. Accusamus, excepturi! Voluptate dignissimos repudiandae minima facere.
```

18% fewer characters, and it's generally pretty easy to see how everything works. Pug and other indent based languages have small differences, but will largely look the same.

With Sass (specifically, the `.sass` indented system) and Stylus, the difference is smaller, and mostly comes down to a bit of developer ergonomics. You don't need to remember to write all those messy `{};` characters (stylus lets you even omit the `:`). They both also provide nesting, mixins, functions, and other utilities, but they're kind of irrelevant to the normal, day to day ergonomics.

## Where they start to fall short

### Technical issues

Indent based syntaxes look very good on the surface, and so many developers dive right into them. Only after using them for a while do you begin to encounter the little flaws that make them less fun to use. And generally, these flaws _are_ fixable, or at least work-aroundable.

Take a recent "flaw" I encountered when writing a style using Stylus. I was trying to make use of the [newer syntax for writing hsl colors with an alpha channel](https://developer.mozilla.org/en-US/docs/Web/CSS/color_value/hsl). Problem is, Stylus internally has a function called `hsl`, that exists for legacy reasons (converting HSL to hex). It has a very specific signature expected, one that matches the "old style" HSL syntax.

```styl
.foo
  background-color hsl(210 100% 52% / 25%)
```

This started throwing compiler errors, and my stylesheet stopped working. There are a couple fixes. Obviously, I could rewrite it in the old style and use `hsla` instead. But stylus also provides an escape hatch to pure CSS, which is what I wound up using instead:

```styl
.foo
  background-color @css { hsl(210 100% 52% / 25%) }
```

Not really great, but I was able to get on with the project.

Another such example is that the indented syntax for Sass, `.sass`, _doesn't support multi-line constructs_. At the time sass was first created, this wasn't really much of a problem, but since then it has become one. `grid-template-areas` rely on newlines to indicate different rows of the grid, and a built-in sass feature, keyword lists, is hobbled by the inability to have multiple lines. There was an issue opened about this in 2011, and it is _still_ open, with no resolution. Dart-sass does support the indent based syntax yes, but it seems relatively limited; bugfixes only appear if they first surface in the `.scss` format, and also happen to manifest themselves in the indent based format. Stylus, for what its worth, supports multi-line constructs via a `\` at the end of lines, indicating a continuation.

Stylus has drifted in and out of maintenance status for the last few years, with the future of the project being uncertain. It works fine now, but as the web continues to move forwards, I worry that more places will need to use the `@css` escape hatch, and at some point you're writing more CSS than Stylus, and might as well just switch over

### The small learning curve

No matter how close these things are to their "native" counterparts, they _are not the same_, and so there is always a technical learning curve. In many organizations, this curve is too much, however gentle, and so they aren't used at all. I think this limits their exposure, and so they're always sort of a side project, with minimal support. `.scss` is _far_ more common to find "out there" than `.sass`, despite the latter existing before the former. Pug is extremely rare in the JS ecosystem, most people either use something like mustache or just JSX. In Elixir land, EEx and variants are more common than Slime, and in ruby the same goes for ERB vs slim/haml.

And that's assuming you even need them. CSS has nesting now. CSS has variables. CSS has all sorts of combinator selectors that can let you write code that's even more terse than you could with preprocessors. JavaScript is gaining newer and better ways to template out HTML, and at the end of the day you can always fall back on template literals.

### The inherent flaws in indent-based syntaxes

Indent based syntaxes are very easy to write. But finding out where blocks start and end can be frustrating. Most editors have systems that help you with this, be it indentation indicators, visible whitespace characters, etc. But you still have to rely on them to know where you are. With a delineated block syntax, you just look for the `}` or the closing tag, and you know that's where it ends.

## I don't want to use them on future projects, and that makes me sad

I love the indent based syntaxes. Throughout my career, I've reached for them time and time again. They've saved countless keystrokes, and when written well, look excellent. But I've moved away from them.

The little annoyances start to mount. Having to use escape hatches all over the place just gets tedious. And trying to figure out if it's a problem with the preprocessor or the output code is often an annoying bit of yak shaving that I could do without.

And god help you maintain consistency if you're working on a team. Stylus is amazing for small passion projects. But it does hamper maintainability. Write a codebase as a solo engineer long enough and you'll start to see inconsistencies in how properties are applied. Some lines will have semicolons separating the property from the values, others won't. Stylus doesn't care, and eventually you won't care either. And if you toss other engineers into the mix, then it becomes even more messy.

Getting templates working isn't hard. Typically, its just install a dependency, add a few lines to a config, and start using it. In Vue.js you have to tag your template with a lang tag: `<template lang="pug">`{lang=html}, but that isn't too bad. But out of the box you don't even have to do that. You can just start writing HTML. And since you're using components, all the messiness of HTML is somewhat soothed and combed down.

I worked on upgrading some stylings on this blog over the past weekend. I moved from hardcoded base font size to respecting the browsers font size, and using those sizes for the few breakpoints I have. Initially I did all my changes in the stylus files that I created with this blog. But I had to use a few escape hatches here and there, mostly around color and the "new" `color-mix`{lang=css} function in CSS, and it left a sour taste in my mouth. I started moving the files over to `.sass`, to get away from the need for escape hatches, thinking "Since Sass is more actively maintained, it will have kept up with these standards". No more issues with `color-mix`{lang=css}, but now I ran smack-dab into the multi-line problem. From there, I just swallowed my opposition, and moved to `.scss` files and syntax across the whole codebase. Vim-surround, textobj-indent, and a few other tricks made this migration rather easy, and now the codebase is fairly clean.

I have no opposition to indent based syntaxes, and would love to continue using them. But the cost-value proposition is currently out of alignment, and unless things change dramatically, will likely stay out of alignment.

[haml]: https://haml.info
[pug]: https://pugjs.org/api/getting-started.html
[sass]: https://sass-lang.com
[slim]: https://slim-template.github.io
[stylus]: https://stylus-lang.com
