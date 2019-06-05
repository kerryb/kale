defmodule Kale.FeatureCase do
  defmacro __using__(options) do
    quote do
      use ExUnit.Case, unquote(options)
      import Kale.FeatureCase, only: :macros

      def step(step, context) do
        case step(
               unquote(__MODULE__).normalise_name(step),
               unquote(__MODULE__).extract_args(step),
               context
             ) do
          %{} = results -> context = context |> Map.merge(results)
          _ -> context
        end
      end
    end
  end

  def agent_name, do: {:global, {__MODULE__, :state, self()}}

  defmacro feature(name, do: block) do
    quote do
      describe unquote(name) do
        unquote(block)
      end
    end
  end

  defmacro scenario(name, body) do
    steps =
      body
      |> String.split(~r/\R/, trim: true)
      |> Enum.filter(&(&1 =~ ~r/^(Given|When|Then|And|But|\*)\b/))
      |> Enum.map(&String.replace(&1, ~r/^\s*\S+\s+/, ""))

    quote do
      test unquote(name), context do
        unquote(steps) |> Enum.reduce(context, fn s, c -> step(s, c) end)
      end
    end
  end

  defmacro defgiven(step, args, context, do: block), do: define_step(step, args, context, block)
  defmacro defwhen(step, args, context, do: block), do: define_step(step, args, context, block)
  defmacro defthen(step, args, context, do: block), do: define_step(step, args, context, block)

  defp define_step(step, args, context, block) do
    quote do
      def unquote({:step, [], [normalise_name(step), args, context]}) do
        unquote(block)
      end
    end
  end

  def normalise_name(step), do: step |> String.replace(~r/\{.*?\}/, "{}")

  def extract_args(step) do
    Regex.scan(~r/\{(.*?)\}/, step, capture: :all_but_first) |> List.flatten()
  end
end
