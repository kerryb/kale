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

      defp when_(step) do
        with {vars, label_chunks} <-
               step
               |> String.split(~r/\{.*?\}/, include_captures: true)
               |> Enum.split_with(fn s -> s =~ ~r/\{.*\}/ end),
             label <- label_chunks |> Enum.join("{}"),
             args <- vars |> Enum.map(fn a -> String.replace(a, ~r/\{(.*)\}/, "\\1") end) do
          when_(label, args)
        end
      end
    end
  end

  defmacro defgiven(step, do: block) do
    quote do
      def given_(unquote(step)) do
        unquote(block)
      end
    end
  end

  defmacro defwhen(step, do: block) do
    with {vars, label_chunks} <-
           step
           |> String.split(~r/\{.*?\}/, include_captures: true)
           |> Enum.split_with(fn s -> s =~ ~r/\{.*\}/ end),
         label <- label_chunks |> Enum.join("{}"),
         var_names <- vars |> Enum.map(fn a -> String.replace(a, ~r/\{(.*)\}/, "\\1") end) do
      quote do
        def when_(unquote(label), values) do
          var!(args) =
            unquote(var_names)
            |> Enum.map(&String.to_atom/1)
            |> Enum.zip(values)
            |> Enum.into(%{})

          unquote(block)
        end
      end
    end
  end
end

defmodule GWTTest do
  use FeatureCase

  test "Adding" do
    given_ "a calculator"
    when_ "I add {2} and {3}"
    then_ "the result is {5}"
  end

  defgiven "a calculator" do
    # this is a no-op
  end

  defwhen "I add {a} and {b}" do
    save(:result, String.to_integer(args.a) + String.to_integer(args.b))
  end

  defp then_("the result is " <> result) do
    assert get(:result) == result |> String.replace(~r/\{(.*)\}/, "\\1") |> String.to_integer()
  end
end
