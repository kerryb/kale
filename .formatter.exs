# Used by "mix format"
locals_without_parens = [
  feature: 2,
  scenario: 2,
  defwhen: 3,
  defgiven: 3,
  defwhen: 3
]

[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  plugins: [Styler],
  locals_without_parens: locals_without_parens,
  export: [locals_without_parens: locals_without_parens]
]
