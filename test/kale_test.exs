defmodule KaleTest do
  use ExUnit.Case, async: true
  use Kale

  setup_all do
    {:ok, foo: "a"}
  end

  feature "Using Kale" do
    setup do
      {:ok, bar: "b"}
    end

    scenario "Parameterised steps and persistent context", """
    Given I start with {18}
    When I add {3} then multiply by {2}
    Then the result is {42}
    """

    scenario "Contexts are isolated between async tests", """
    Given I start with {16}
    When I add {7} then multiply by {3}
    Then the result is {69}
    """

    scenario "context can be returned as maps, keyword lists or :ok tuples", """
    Given a step that returns context as a map
    And a step that returns context as a keyword list
    And a step that returns context as an :ok, <map> tuple
    And a step that returns context as an :ok, <keyword list> tuple
    Then all context is stored
    """

    scenario "Lines not beginning with Given, When, Then, And, But or * are ignored", """
    Given I start with {16}
    This is just a note
    When I add {7} then multiply by {3}
    And I add {1} then multiply by {2}
    Anders could have written this line, but it's not an And
    But I add {2} then multiply by {4}
    * I add {5} then multiply by {5}
    Then the result is {568}
    """

    scenario "data returned by setup callbacks is merged into the context", """
    Then foo is {a} and bar is {b}
    """

    scenario "full context is always retained, even if steps don't use it", """
    When a step definition only pattern-matches some of the context
    And another step definition omits the context altogether
    Then the full context is still available to subsequent steps
    """
  end

  defgiven "I start with {a}" do
    # No need to use context argument if it's not required
    %{result: String.to_integer(a)}
  end

  defgiven "a step that returns context as a map" do
    %{a: 1}
  end

  defgiven "a step that returns context as a keyword list" do
    [b: 2]
  end

  defgiven "a step that returns context as an :ok, <map> tuple" do
    {:ok, %{c: 3}}
  end

  defgiven "a step that returns context as an :ok, <keyword list> tuple" do
    {:ok, [d: 4]}
  end

  defwhen "I add {a} then multiply by {b}", %{result: result} do
    %{result: (result + String.to_integer(a)) * String.to_integer(b)}
  end

  defwhen "a step definition only pattern-matches some of the context", %{foo: _} do
    %{baz: "c"}
  end

  defthen "another step definition omits the context altogether" do
    %{qux: "e"}
  end

  defthen "the result is {result}", context do
    assert context.result == String.to_integer(result)
  end

  defthen "foo is {foo} and bar is {bar}", context do
    assert context.foo == foo
    assert context.bar == bar
  end

  defthen "the full context is still available to subsequent steps", context do
    assert context.bar == "b"
  end

  defthen "all context is stored", context do
    assert context |> Map.take([:a, :b, :c, :d]) == %{a: 1, b: 2, c: 3, d: 4}
  end
end
