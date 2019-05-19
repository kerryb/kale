defmodule GWTTest do
  use FeatureCase, async: true

  test "Adding" do
    given_ "a calculator"
    when_ "I add {2} and {3}"
    then_ "the result is {5}"
  end

  test "Adding again" do
    given_ "a calculator"
    when_ "I add {2} and {40}"
    then_ "the result is {42}"
  end

  defgiven "a calculator" do
    # this is a no-op
  end

  defwhen "I add {a} and {b}" do
    save(:result, String.to_integer(args.a) + String.to_integer(args.b))
  end

  defthen "the result is {c}" do
    assert get(:result) == String.to_integer(args.c)
  end
end
