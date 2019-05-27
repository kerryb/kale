defmodule KaleTest do
  use Kale.FeatureCase, async: true

  test "Parameterised steps and persistent context" do
    given_ "I start with {18}"
    when_ "I add {3} then multiply by {2}"
    then_ "the result is {42}"
  end

  test "Contexts are isolated between async tests" do
    given_ "I start with {16}"
    when_ "I add {7} then multiply by {3}"
    then_ "the result is {69}"
  end

  defgiven "I start with {a}" do
    save(:result, String.to_integer(args.a))
  end

  defwhen "I add {a} then multiply by {b}" do
    save(:result, (get(:result) + String.to_integer(args.a)) * String.to_integer(args.b))
  end

  defthen "the result is {result}" do
    assert get(:result) == String.to_integer(args.result)
  end
end
