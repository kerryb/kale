defmodule KaleTest do
  use Kale.FeatureCase, async: true

  feature "Using Kale" do
    scenario "Parameterised steps and persistent context" do
      given_ "I start with {18}"
      when_ "I add {3} then multiply by {2}"
      then_ "the result is {42}"
    end

    scenario "Contexts are isolated between async tests" do
      given_ "I start with {16}"
      when_ "I add {7} then multiply by {3}"
      then_ "the result is {69}"
    end
  end

  defgiven "I start with {a}", [a], _ do
    %{result: String.to_integer(a)}
  end

  defwhen "I add {a} then multiply by {b}", [a, b], %{result: result} do
    %{result: (result + String.to_integer(a)) * String.to_integer(b)}
  end

  defthen "the result is {result}", [result], context do
    assert context.result == String.to_integer(result)
  end
end
