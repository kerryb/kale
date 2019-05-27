# Kale

Basic given-when-then steps for ExUnit tests. This is currently little more
than a spike: it's probably not ready to use, and the API is certainly not
stable.

## Features

  * define tests as sequences of calls to `given_`, `when_` and `then_` (unfortunately `when` is a reserved word)
  * match steps by calling `defwhen` etc with a string matching the one used in the step
  * interpolate values into step descriptions using {braces}
    * placeholder variable names are available as methods on the magic `args` variable
  * pass data between steps by calling `save` and `get` with a key
    * data is stored in a per-test Agent, allowing tests to run in parallel

## TODO

  * Remove the magic `args`, and `save` & `get`
    * Pass args and context via arguments to `defwhen` etc
    * Allow pattern matching
    * Return values to be saved from the function

## Usage

See the tests for examples.

## Why Kale?

As a nod to [Spinach](https://github.com/codegram/spinach).
