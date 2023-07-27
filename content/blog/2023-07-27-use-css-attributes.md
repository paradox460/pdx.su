---
date: 2023-07-27T10:33:42-06:00
---

# Use CSS attributes not classes

A common pattern in CSS, particularly when using frameworks, is to use a bunch of classes to affect how something looks. Things like `btn btn-primary btn-blue` are far too common. There is a better way, with support built into CSS too

## What's the purpose

Let's dissect the classes being used on our aforementioned button. We've got `btn`, which is pretty straight forwards, it indicates that it's a button. Then we've got `btn-primary`, which probably indicates that the button is somehow an important or primary button. Then we've got `btn-blue`, which means our button has a blue-ish color.

Only one of those is actually meaningful. The rest are presentational aspects. And there's no way to tell which ones can mix and which can't. We can intuit that `btn-blue` and `btn-red` don't mix, but _maybe they do_, and we'd get a purple button.

What we're trying to do is affect how the button is rendered, by changing a few other properties of said button. Lucky for us, HTML already gives us the ability to set attributes, without having to over-rely on the `class` attribute

## Use Data attributes

If we define our button like this

```html
<div class="btn" data-primary data-color="blue">Button</div>
```

We can then style it like this:

```css
.btn {
  border: 1px solid;
  padding: 5px;
}

.btn[data-color="blue"] {
  background: blue;
  color: white;
}
.btn[data-color="red"] {
  background: red;
  color: white;
}


.btn[data-primary] {
  font-weight: bold;
}
```

If you use sass or some other tool that allows nesting CSS, you can clean that up even further.

Now there's a very clear separation of concerns. The class indicates _what_ this thing is supposed to be, and the data attributes affect parts of how it looks. The primary appearance is styled by classes still, but secondary aspects are given to us from data attributes.

## Read more

+ [Attribute Selectors](http://developer.mozilla.org/en-US/docs/Web/CSS/Attribute_selectors)
+ [Data attributes](http://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes/data-*)
