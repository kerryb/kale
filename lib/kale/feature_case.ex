defmodule Kale.FeatureCase do
  defmacro __using__(options) do
    quote do
      use ExUnit.Case, unquote(options)
      import Kale.FeatureCase

      setup do
        {:ok, _} = Agent.start(fn -> %{} end, name: Kale.FeatureCase.agent_name())
        :ok
      end

      defp save(key, value) do
        Agent.update(Kale.FeatureCase.agent_name(), fn state ->
          Map.put(state, key, value)
        end)
      end

      defp get(key), do: Agent.get(Kale.FeatureCase.agent_name(), fn state -> state[key] end)

      def step(step), do: step(normalise_name(step), extract_args(step))

      defdelegate given_(step), to: __MODULE__, as: :step
      defdelegate when_(step), to: __MODULE__, as: :step
      defdelegate then_(step), to: __MODULE__, as: :step
    end
  end

  def agent_name, do: {:global, {__MODULE__, :state, self()}}

  defmacro defgiven(step, args, do: block), do: define_step(step, args, block)
  defmacro defwhen(step, args, do: block), do: define_step(step, args, block)
  defmacro defthen(step, args, do: block), do: define_step(step, args, block)

  defp define_step(step, args, block) do
    quote do
      def unquote({:step, [], [normalise_name(step) | [args]]}) do
        unquote(block)
      end
    end
  end

  def normalise_name(step), do: step |> String.replace(~r/\{.*?\}/, "{}")

  def extract_args(step) do
    Regex.scan(~r/\{(.*?)\}/, step, capture: :all_but_first) |> List.flatten()
  end
end
