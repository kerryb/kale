defmodule Kale do
  # credo:disable-for-this-file Credo.Check.Warning.UnsafeToAtom
  # credo:disable-for-this-file Credo.Check.Readability.Specs

  @moduledoc ~s'''
  An `ExUnit` test case for writing features using Kale.

  # Usage

  ```elixir
  defmodule MyTest do
    use ExUnit.Case, async: true
    use Kale

    feature "Feature description here" do
      scenario "Scenario description here", """
      Given some precondition
      When action {foo} happens
      Then the result is {bar}
      """
    end

    defgiven "some precondition" do
      # ...
    end

    defwhen "action {action} happens" do
      # interpolated variables are magically available
      result = do_something(action)
      # if the step returns a {:reply, _} tuple containing a map or keyword
      # list, it will be merged with the test context
      {:reply, result: result}
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

  alias Kale.Utils

  defmacro __using__(_) do
    quote do
      import Kale.Macros

      defp step(step, context) do
        case step(
               Utils.normalise_name(step),
               Utils.extract_args(step),
               context
             ) do
          {:reply, results} when is_map(results) -> Map.merge(context, results)
          {:reply, [{_, _} | _] = results} -> Map.merge(context, Map.new(results))
          _ -> context
        end
      end
    end
  end
end
