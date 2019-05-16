defmodule FeatureCase do
  defmacro __using__(options) do
    quote do
      use ExUnit.Case, unquote(options)
      import FeatureCase

      setup_all do
        {:ok, _} = Agent.start(fn -> %{} end, name: __MODULE__)
        :ok
      end

      defp save(key, value) do
        Agent.update(__MODULE__, fn state -> Map.put(state, key, value) end)
      end

      defp get(key), do: Agent.get(__MODULE__, fn state -> state[key] end)
    end
  end

  defmacro defgiven(name, do: block) do
    quote do
      def given_(unquote(name)) do
        unquote(block)
      end
    end
  end
end

defmodule GWTTest do
  use FeatureCase

  test "Adding" do
    given_ "a calculator"
    when_ "I add 2 and 3"
    then_ "the result is 5"
  end

  defgiven "a calculator" do
    # this is a no-op
  end

  defp when_("I add " <> <<a::bytes-size(1)>> <> " and " <> <<b::bytes-size(1)>>) do
    save(:result, String.to_integer(a) + String.to_integer(b))
  end

  defp then_("the result is " <> result) do
    assert get(:result) == String.to_integer(result)
  end
end
