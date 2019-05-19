# GWT

A spike looking at adding basic given-when-then steps to ExUnit tests.

## Features

* define tests as sequences of calls to `given_`, `when_` and `then_` (unfortunately `when` is a reserved word)
* match steps by calling `defwhen` etc with a string matching the one used in the step
* interpolate values into step descriptions using {braces}
  * placeholder variable names are available as methods on the magic `args` variable
* pass data between steps by calling `save` and `get` with a key
  * data is stored in a per-test Agent, allowing tests to run in parallel
