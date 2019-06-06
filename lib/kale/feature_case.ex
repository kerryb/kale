defmodule Kale.FeatureCase do
  defmacro __using__(options) do
    quote bind_quoted: [options: options] do
      use ExUnit.Case, options
      import Kale.FeatureCase, only: :macros

      def step(step, context) do
        case step(
               Kale.FeatureCase.normalise_name(step),
               Kale.FeatureCase.extract_args(step),
               context
             ) do
          %{} = results -> context |> Map.merge(results)
          _ -> context
        end
      end
    end
  end

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

  @empty_context quote do: %{}

  defmacro defgiven(step, context \\ @empty_context, do: block) do
    define_step(step, context, block)
  end

  defmacro defwhen(step, context \\ @empty_context, do: block) do
    define_step(step, context, block)
  end

  defmacro defthen(step, context \\ @empty_context, do: block) do
    define_step(step, context, block)
  end

  defp define_step(step, context, block) do
    quoted_args =
      step
      |> extract_args()
      |> Enum.map(&String.to_atom/1)
      |> Enum.map(&{&1, [], __MODULE__})
      |> Enum.map(&quote do: var!(unquote(&1)))

    quote do
      def unquote({:step, [], [normalise_name(step), quoted_args, context]}) do
        unquote(block)
      end
    end
  end

  def normalise_name(step), do: step |> String.replace(~r/\{.*?\}/, "{}")

  def extract_args(step) do
    Regex.scan(~r/\{(.*?)\}/, step, capture: :all_but_first) |> List.flatten()
  end
end
