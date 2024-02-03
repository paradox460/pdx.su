---
date: "2023-06-14T00:00:00-06:00"
updated: "2023-06-21T02:11:28-06:00"
permalink: "/blog/:year-:month-:day-some-elixir-test-tricks"
---

# Some Elixir Testing Tricks

Testing in Elixir is pretty great. ExUnit, combined with the functional nature of Elixir, makes it very easy to test almost everything in your codebase. However, it is very easy for boilerplate to creep into your tests. Common setup patterns, similar assertions, and more can quickly make your test suite feel cumbersome. But ExUnit files are _just_ Elixir files. So you can write bits of code that will help you out tremendously.

## Common Setup

You're testing something in your codebase, and you have to set up a user, maybe an account or organization, and maybe even some content to "work" with. You've got some fixtures or factories ready to go, so you just write the setup code inline in the test. But now you need to write another test. So you extract the setup to a [`setup/1`][se1] block. Pretty good. Now all the other tests in that file or describe group will have those steps run before they do, and any results added to the context.

But now you have another test file, and it's got similar, but slightly different, setup steps. You copy the setup block, change it slightly, and proceed with things. Repeat that over the next several other test files, and now you're in an unfortunate situation. You've got a bunch of _similar_, but not identical setup steps. Some tests need users of different permission levels, some need different content, others need their own special things.

### Extracting Universal steps to a `__using__` macro

A common approach is to put the most universal setup steps into a custom `__using__` macro, and then using it via `use`. If you're using Phoenix, you already have a macro generated for you, in your `test/support/conn_case.ex` file, and similar ones for database access and channels. You can just add a `setup` block to these macros, and it will effectively be included in every test that needs it.

This is great for setup steps that _need_ to occur universally. But that's a surprisingly small number of steps. You might assume that your user setup and auth steps need to be universal, but they don't. How are you going to test if unauthenticated users are prohibited from using parts of your application?

In the past I've seen people split out a separate case, or add options to the `__using__` macro, that are passed in from runtime. Things like:

```elixir
defmodule MyAppWeb.SomeBigTest do
  use MyAppWeb.ConnCase, noauth: true
```

This _works_, but it quickly becomes opaque. You have to document all the various `opts` you can pass to the `__using__` macro, and discoverability is minimal. And as your test suite grows, the number of `opts` you have to support, plus the ways they can be combinant, can get overwhelming.

### Setup functions

An alternative that _supplements_ universal setup steps is _setup functions_. While [`setup/1`][se1] nominally accepts a block, it also accepts a _single arity function_, which is called with the current context. This lets you define a collection of discrete setup functions, that can be mixed together to handle your test case setup. If you edit your aforementioned using macro to import a module containing these setup functions, you can use them anywhere the macro is used, however you like.

Take for example the following helper module:

```elixir [support/helpers.ex]
defmodule MyApp.Support.Helpers do
  def insert_user(context) do
    # Some code that sets up a user and adds it to the context
  end

  def authorize(context) do
    # Some code that takes a user off the context and "authenticates" them
  end

  def insert_content(context) do
    # Generate some content
  end

  # More functions...
end
```

As you can see, those functions are pretty small. They implement single, simple concerns, and are pretty straightforwards, from the name alone.

If you added them to your `__using__` macros, you can then simply call `setup :functionname` anywhere you'd put a setup block, and it will be called, and passed in the current context. You can have each setup function take and return things to the context, and build pretty powerful setup pipelines.

```elixir [somebigtest.exs]{4-5}
defmodule MyAppWeb.SomeBigTest do
  use MyAppWeb.ConnCase

  setup :insert_user
  setup :authorize

  test "test_something", %{current_user: user} do
    # ...
  end
end
```

Very clean, and for test suites that don't need to have a user or an authed user, you can simply omit them.

### Configuration

You've now got a pretty clean setup system. You can pick and choose whole chunks of setup, and everything more or less works. But you're still in a position where you have to write a _bunch_ of different functions for various permutations of how you'd set up your test cases. Maybe you need both a regular user and an admin. Whatever the case, having to have an `insert_user/1` and an `insert_admin/1` that share much of the same code. Maybe you extracted them to a private function inside your Helpers module. That works, but there's a better way.

You might also want to have slightly different configuration for _each_ test in a suite. They all call the same functions, but you might want each to be subtly different.

There's a nice solution for this, _built into ExUnit_. The `@tag`.

Out of the box, without any configuration, you can change any value in the `context` of your tests using the `@tag` attribute (and the `@describetag` for your `describe` blocks). Since `setup` is run _once per test_, you can simply call `@tag someattr: somevalue` before each test to override the values generated by your `setup` functions. Have a file-wide setup for inserting and authorizing a user, but want to test what happens when `current_user` is `nil`? Trivial, `@tag current_user: nil`.

But that's just overriding values from the setup with your own values, on a per test basis. Better than nothing, but you can do better still. Remember that the custom functions we wrote for `setup` _receive the context as their parameter_. You can use this to accept configuration values from the context and make your setup functions do different things.

Take this example of changing `insert_user/1` to handle things like the user being an administrator:

```elixir
def insert_user(%{admin: true}) do
  # some code that makes a user and sets them up as an administrator
end
def insert_user(context) do
  # code that just creates a normal user
end
```

Now, without changing the `setup` calls at the top of the test suite (or `describe` block), we can make tags have an admin user on the fly:

```elixir {1}
@tag admin: true
test "an admin can delete a post" do
  # something that tests this
end

test "a regular user cannot delete a post" do
  # similar code, but it would refute that the post was deleted
end
```

That's it! Very simple, very flexible, very useful.

I've started using the above patterns all over my testing, and now can't imagine working without them.

## Custom Assertions

Another common smell I'll see all over test suites is a lot of boilerplate around assertions. You'll see a lot around things like testing HTML matches certain values, or certain elements are present, or in an evented system that an event was received. People coming from other testing frameworks seem to think there's something magic about the native `assert`, and may ask if there are other libraries, such as how Rspec has the matchers libraries in Ruby.

Assert, and its sibling refute, are just plain Elixir code, same as most everything else in Elixir and ExUnit. You can write your own asserting functions and macros trivially easy.

### Checking for presence of an HTML element

A common pattern when testing web apps is to see if the generated output contains a particular element. When working on LiveView apps, this is even more common. Generally, a lot of test suites will start off by just doing simple string matching, such as `html =~ "<div class=\"bar\""`. This proves to be quite fragile and prone to dumb breakage. So eventually most developers will implement something like this, using the [Floki](https://github.com/philss/floki) library:

```elixir
assert html |> Floki.parse_fragment!() |> Floki.find(".bar")
```

This does the job, but its rather verbose, and having to write it _every_ time you want to check if an element exists is tedious.

Instead, you can turn it into a simple macro:

```elixir
defmacro assert_html(html, selector) do
  quote do
   assert unquote(html) |> Floki.parse_fragment!() |> Floki.find(unquote(selector))
  end
end
```

And use it like this:

```elixir
assert_html html, ".bar"
```

<md-note icon='️💡'>

You don't have to use macros for these, they can be quite easily written as functions. However, if you write them as functions, you _must_ import the appropriate "things" into the module they are defined in.

By using macros, you can step around this, because the macros generate code that lives at the call-site, which already has access to the appropriate "things"

</md-note>

### Handling Event Boilerplate

In evented Elixir, we have the useful assertion `assert_receive`. This lets you state that a process should get an event within a timeout, and even specify the message to error with in the case no event is received.

But if your events have a particular pattern they follow, i.e. `{:event_fired, %{action: FooEvent}}`, and you want to implement custom timeouts other than the default 100ms, or custom error messages, it can get pretty verbose pretty quickly.

```elixir
assert_receive {:event_fired, %{action: FooEvent}}, 1000, "Did not receive event"
```

Not terrible, but now you have to do that all over your tests, and if you want to change the failure message or timeout, you have to update _all_ the implementation sites.

Macros can simplify this:

```elixir
defmacro assert_event(event) do
  quote do
    event_name = unquote(event).name

    assert_receive {:event_fired, e}, 1000, "Did not receive event"

    assert event_name == e.name

    e
  end
end
```

You can then call this like so

```elixir
event = assert_event FooEvent
```

Since the macro returns the matched event object, you can use it further in your test suite:

```elixir
event = assert_event FooEvent
assert "some event data" == event.data
```

If you want a further optimization, you can add a version of `assert_event` that accepts and calls a function, giving said function the event. This lets you treat the function as a lambda, and keep any assertions on said event scoped to only that event. In busy test suites, where you're asserting event after event, this can dramatically improve readability.

```elixir
defmacro assert_event(event) do
  quote do
    event_name = unquote(event).name

    assert_receive {:event_fired, e}, 1000, "Did not receive event"

    assert event_name == e.name

    e
  end
end

defmacro assert_event(event, func) do
  quote do
    event = assert_event(unquote(event))

    unquote(func).(event)
  end
end
```

And you can use it like so:

```elixir
assert_event(FooEvent, fn e ->
  assert "some event data == e.data
end)
```

Very clean!

## Generating test suites from a matrix

Often you'll find cases where you need to test that a variety of cases are valid, and a variety of cases are invalid. These test suites might be largely identical, apart from the variable factor. Since tests are just elixir, you can do this:

```elixir
describe "Post Removal" do
  setup :create_post

  for role <- [:moderator, :admin], own <- [true, false] do
    @tag own_post: own
    test "#{role} can remove #{if own, do: "their own", else: "someone else's"} post" do
      # some code that removes the post and asserts its removal
    end
  end

  @tag own_post: true
  test "users can remove their own post" do
    # some code that removes the post and asserts its removal
  end

  @tag own_post: false
  test "users can't remove other people's posts" do
    # some code that attempts to remove the post and refutes if the removal was successful
  end
end
```

While this is a contrived example, you can see how we were able to test 4 test cases for the moderator and admin roles with a single test, and then test the more specific user test cases separately.

Remember, all that ExUnit provides is some useful tools around testing. Under the hood, its _just_ Elixir.


----

## Updates

+ Post was updated to add a note about why macros were used instead of plain functions

[se1]: https://hexdocs.pm/ex_unit/ExUnit.Callbacks.html#setup/1
