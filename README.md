# Kale

Basic given-when-then steps for ExUnit tests. This is currently little more
than a spike: it's probably not ready to use, and the API is certainly not
stable.

## Features

  * define tests with multline strings using Given, When, Then, And, But and *
    * other lines are ignored
  * match steps by calling `defwhen` etc with a string matching the one used in the step
    * note that it doesn't actually matter whether you use `defwhen`, `defthen` etc
    * step definitions take the `ExUnit` context as their second argument
  * interpolate values into step descriptions using {braces}
    * concrete values from the steps are automatically available using the variable name in braces

## Usage

See the tests for examples for now.

## Why Kale?

As a nod to [Spinach](https://github.com/codegram/spinach).
