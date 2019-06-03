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

      defp get(key) do
        Agent.get(Kale.FeatureCase.agent_name(), fn state -> state[key] end)
      end

      def step(step) do
        {label, args} = parse_step(step)
        step(label, args)
      end

      defdelegate given_(step), to: __MODULE__, as: :step
      defdelegate when_(step), to: __MODULE__, as: :step
      defdelegate then_(step), to: __MODULE__, as: :step
    end
  end

  def agent_name, do: {:global, {__MODULE__, :state, self()}}

  defmacro defgiven(step, do: block), do: define_step(step, block)
  defmacro defwhen(step, do: block), do: define_step(step, block)
  defmacro defthen(step, do: block), do: define_step(step, block)

  defp define_step(step, block) do
    case Kale.FeatureCase.parse_step(step) do
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
    with args <- ~r/\{(.*?)\}/ |> Regex.scan(step, capture: :all_but_first) |> List.flatten(),
         label <- step |> String.replace(~r/\{.*?\}/, "{}") do
      {label, args}
    end
  end
end
