defmodule FeatureCase do
  defmacro __using__(options) do
    quote do
      use ExUnit.Case, unquote(options)
      import FeatureCase

      setup do
        {:ok, _} = Agent.start(fn -> %{} end, name: {:global, FeatureCase.agent_name()})
        :ok
      end

      defp save(key, value) do
        Agent.update({:global, FeatureCase.agent_name()}, fn state ->
          Map.put(state, key, value)
        end)
      end

      defp get(key),
        do: Agent.get({:global, FeatureCase.agent_name()}, fn state -> state[key] end)

      def step(step) do
        {label, args} = parse_step(step)
        step(label, args)
      end

      defdelegate given_(step), to: __MODULE__, as: :step
      defdelegate when_(step), to: __MODULE__, as: :step
      defdelegate then_(step), to: __MODULE__, as: :step
    end
  end

  def agent_name, do: "state-for-#{inspect(self())}"

  defmacro defgiven(step, do: block), do: define_step(step, block)
  defmacro defwhen(step, do: block), do: define_step(step, block)
  defmacro defthen(step, do: block), do: define_step(step, block)

  defp define_step(step, block) do
    case FeatureCase.parse_step(step) do
      {label, []} ->
        quote do
          def step(unquote(label), _values), do: unquote(block)
        end

      {label, var_names} ->
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

  def parse_step(step) do
    with {vars, label_chunks} <-
           step
           |> String.split(~r/\{.*?\}/, include_captures: true, trim: true)
           |> Enum.split_with(fn s -> s =~ ~r/\{.*\}/ end),
         label <- label_chunks |> Enum.join("{}"),
         args <- vars |> Enum.map(fn a -> String.replace(a, ~r/\{(.*)\}/, "\\1") end) do
      {label, args}
    end
  end
end

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
