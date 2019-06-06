defmodule Kale.FeatureCase do
  @moduledoc ~s'''
  An `ExUnit` test case for writing features using Kale.

  # Usage

  ```
  defmodule MyTest do
    use Kale.FeatureCase, async: true

    feature "Feature description here" do
      scenario "Scenario description here", """
      Given some precondition
      When action {foo} happens
      Then the result is {bar}
      """

    defgiven "some precondition" do
      # ...
    end

    defwhen "action {action} happens" do
      # interpolated variables are magically available
      result = do_something(action)
      # if the step returns a map, it will be merged with the test context
      %{result: result}
    end

    defthen "the result is {expected}", %{result: result} do
      # Optional second argument for context, as per standard ExUnit
      assert result == expected
    end
  end
  ```

  Each `feature` generates a `describe`, and each `scenario` a `test`. Standard
  ExUnit features such as `setup` can be used as normal.

  To avoid the formatter inserting extra parens, you can specify `import_deps:
  [:kale]` in your `.formatter.exs`.
  '''

  defmacro __using__(options) do
    quote bind_quoted: [options: options] do
      use ExUnit.Case, options
      import Kale.FeatureCase, only: :macros

      defp step(step, context) do
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

  @doc """
  Generate a feature block, which corresponds to an ExUnit `describe`.
  """
  defmacro feature(name, do: block) do
    quote do
      describe unquote(name) do
        unquote(block)
      end
    end
  end

  @doc """
  Generate a scenario block, which corresponds to an ExUnit `test`.
  """
  defmacro scenario(name, body) do
    steps =
      body
      |> String.split(~r/\R/, trim: true)
      |> Enum.filter(&valid_step?/1)
      |> Enum.map(&remove_keyword/1)

    quote do
      test unquote(name), context do
        unquote(steps) |> Enum.reduce(context, fn s, c -> step(s, c) end)
      end
    end
  end

  @empty_context quote do: %{}

  @doc """
  Generate a step definition matching a particular string and optionally a
  context map. See the module documentation for usage examples.

  The given, when and then steps are actually interchangeable &ndash; the
  separate macros are provided for readability only.
  """
  defmacro defgiven(step, context \\ @empty_context, do: block) do
    define_step(step, context, block)
  end

  @doc """
  An alias for `defgiven/2`.
  """
  defmacro defwhen(step, context \\ @empty_context, do: block) do
    define_step(step, context, block)
  end

  @doc """
  An alias for `defgiven/2`.
  """
  defmacro defthen(step, context \\ @empty_context, do: block) do
    define_step(step, context, block)
  end

  @doc false
  def normalise_name(step), do: step |> String.replace(~r/\{.*?\}/, "{}")

  @doc false
  def extract_args(step) do
    Regex.scan(~r/\{(.*?)\}/, step, capture: :all_but_first) |> List.flatten()
  end

  defp define_step(step, context, block) do
    quoted_args = step |> extract_args() |> Enum.map(&arg_string_to_quoted_var/1)

    quote do
      defp unquote({:step, [], [normalise_name(step), quoted_args, context]}) do
        unquote(block)
      end
    end
  end

  defp valid_step?(step), do: step =~ ~r/^(Given|When|Then|And|But|\*)\b/
  defp remove_keyword(step), do: String.replace(step, ~r/^\s*\S+\s+/, "")

  defp arg_string_to_quoted_var(arg) do
    quote do: var!(unquote({String.to_atom(arg), [], __MODULE__}))
  end
end
