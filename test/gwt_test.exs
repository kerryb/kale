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

      def step(step) do
        with {vars, label_chunks} <-
               step
               |> String.split(~r/\{.*?\}/, include_captures: true, trim: true)
               |> Enum.split_with(fn s -> s =~ ~r/\{.*\}/ end),
             label <- label_chunks |> Enum.join("{}"),
             args <- vars |> Enum.map(fn a -> String.replace(a, ~r/\{(.*)\}/, "\\1") end) do
          step(label, args)
        end
      end

      defdelegate given_(step), to: __MODULE__, as: :step
      defdelegate when_(step), to: __MODULE__, as: :step
      defdelegate then_(step), to: __MODULE__, as: :step
    end
  end

  defmacro defgiven(step, do: block), do: define_step(step, block)
  defmacro defwhen(step, do: block), do: define_step(step, block)
  defmacro defthen(step, do: block), do: define_step(step, block)

  defp define_step(step, block) do
    with {vars, label_chunks} <-
           step
           |> String.split(~r/\{.*?\}/, include_captures: true, trim: true)
           |> Enum.split_with(fn s -> s =~ ~r/\{.*\}/ end),
         label <- label_chunks |> Enum.join("{}"),
         var_names <- vars |> Enum.map(fn a -> String.replace(a, ~r/\{(.*)\}/, "\\1") end) do
      quote do
        def step(unquote(label), values) do
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

  defthen "the result is {c}" do
    assert get(:result) == String.to_integer(args.c)
  end
end
