# Kale

Basic given-when-then steps for ExUnit tests.

## Why?

I have previously used [White Bread](https://github.com/meadsteve/white-bread)
and [Cabbage](https://github.com/cabbage-ex/cabbage) for writing Cucumber-style
(Gherkin) tests, but decided I didn't really need the extra complexity over
simple ExUnit tests. However, I quite like writing acceptance tests in a
"given, when, then" format &ndash; I find it makes the described functionality
easier to read, even if you aren't going the full BDD route and writing the
scenarios with your customers.

This library is an experiment to try to come up with a minimal layer on top of
ExUnit to allow this. It was also an excuse to delve into the world of Elixir
metaprogramming.

Kale does **not** implement the full gherkin language. Instead it uses simple
string matching (no regexes) with the ability to explicitly interpolate values
by surrounding them with `{}`.

### Why "Kale"?

As a nod to [Spinach](https://github.com/codegram/spinach).

## Installation

Kale is [available in Hex](https://hex.pm/docs/publish), and can be installed
by adding it to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:kale, "~> 0.5.0", only: :test}
  ]
end
```

Then run `mix deps.get`.

If you want to import Kale's formatter rules, import it in your `.formatter.exs`:

```elixir
[
  # ... 
  import_deps: [:kale]
]
```

## Usage

In your test, `use Kale.FeatureCase`:

```elixir
defmodule MyTest do
  use Kale.FeatureCase, async: true

  # ...
end
```

Then write a `feature` (which corresponds to an ExUnit `describe`) containing
one or more scenarios:

```elixir
feature "Feature description here" do

  scenario "Scenario description here", """
  Given some precondition
  When action {foo} happens
  Then the result is {bar}
  """

  scenario "Another scenario", """
  ...
  """
end
```

Each scenario has a description, and a multiline string containing a list of
steps, which should all begin with one of `Given`, `When`, `Then`, `And`, `But`
or `*`. Lines beginning with anything else are treated as comments and ignored.

Each unique step needs a definition, which needs to be created in the test
module by calling `defgiven`, `defwhen` or `defthen`. Technically it doesn't
matter which of the three you use, but it's recommended to use the one that
matches the step for redability.

The simplest form of step definition just takes a literal string argument
matching the step from the scenario, and a block of code to execute:

```elixir
defgiven "some precondition" do
  # ...
end
```

If you need to access the ExUnit context, it can be provided as a second
argument:

```elixir
defgiven "some precondition", context do
  login(context.user)
end
```

You can also pattern match specific values from the context:

```elixir
defgiven "some precondition", %{user: user} do
  login(context.user)
end
```

If a step definition returns a map, a keyword list, or an `{:ok, context}`
tuple, where `context` is a map or a keyword list, it will be merged into the
context for future steps in the same scenario. for example to store a value for
`session`:

```elixir
defgiven "some precondition", %{user: user} do
  session = login(context.user)
  %{session: session}
end
```

Values can be interpolated by wrapping them in `{}`. The value from the step in
the scanario will be available within the body of the step definition using the
variable name provided:

```elixir
defwhen "action {action} happens" do
  do_something(action)
end
```

Tests are run just like normal ExUnit tests (which is what the compile to).
This includes being able to specify the line number of the scenario or feature.

Tests are reported as "features" by ExUnit, separately from other tests:

```
$ mix test
................

Finished in 0.08 seconds
6 features, 10 tests, 0 failures

Randomized with seed 955579
```

## Development

To build the project after cloning:

```bash
$ mix deps.get
$ make
