defmodule Kale.FeatureCase do
  defmacro __using__(options) do
    quote do
      use ExUnit.Case, unquote(options)
      import Kale.FeatureCase

      setup do
        {:ok, _} = Agent.start(fn -> %{} end, name: Kale.FeatureCase.agent_name())
        :ok
      end

      def step(step) do
        case step(normalise_name(step), extract_args(step), Kale.FeatureCase.context()) do
          %{} = results -> Kale.FeatureCase.update_context(results)
          _ -> :ok
        end
      end

      defdelegate given_(step), to: __MODULE__, as: :step
      defdelegate when_(step), to: __MODULE__, as: :step
      defdelegate then_(step), to: __MODULE__, as: :step
    end
  end

  def agent_name, do: {:global, {__MODULE__, :state, self()}}

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

  def context, do: Agent.get(Kale.FeatureCase.agent_name(), & &1)

  def update_context(results) do
    Agent.update(Kale.FeatureCase.agent_name(), fn state ->
      state |> Map.merge(results)
    end)
  end
end
