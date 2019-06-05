# Kale

Basic given-when-then steps for ExUnit tests. This is currently little more
than a spike: it's probably not ready to use, and the API is certainly not
stable.

## Features

  * define tests with multline strings using Given, When, Then, And, But and *
    * other lines are ignored
  * match steps by calling `defwhen` etc with a string matching the one used in the step
    * note that it doesn't actually matter whether you use `defwhen`, `defthen` etc
  * interpolate values into step descriptions using {braces}
  * step definitions take a list of placeholder variables, and the `ExUnit` context

## Usage

See the tests for examples for now.

## Why Kale?

As a nod to [Spinach](https://github.com/codegram/spinach).
