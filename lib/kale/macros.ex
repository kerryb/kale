defmodule Kale.Macros do
  # credo:disable-for-this-file Credo.Check.Warning.UnsafeToAtom
  # credo:disable-for-this-file Credo.Check.Readability.Specs
  @moduledoc """
  Macros, automatically imported by `use Kale`.
  """

  alias Kale.Utils

  @doc """
  Generate a feature block, which corresponds to an ExUnit `describe`.
  """
  @spec feature(String.t(), do: Macro.t()) :: Macro.t()
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
  @spec scenario(String.t(), String.t()) :: Macro.t()
  defmacro scenario(name, body) do
    steps =
      body
      |> String.split(~r/\R/, trim: true)
      |> Enum.filter(&valid_step?/1)
      |> Enum.map(&remove_keyword/1)

    quote(bind_quoted: [name: name, steps: steps]) do
      test_name = ExUnit.Case.register_test(__ENV__, :feature, name, [])

      def unquote(test_name)(context) do
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
  @spec defgiven(String.t(), Macro.t(), do: Macro.t()) :: Macro.t()
  defmacro defgiven(step, context \\ @empty_context, do: block) do
    define_step(step, context, block)
  end

  @doc """
  An alias for `defgiven/2`.
  """
  @spec defwhen(String.t(), Macro.t(), do: Macro.t()) :: Macro.t()
  defmacro defwhen(step, context \\ @empty_context, do: block) do
    define_step(step, context, block)
  end

  @doc """
  An alias for `defgiven/2`.
  """
  @spec defthen(String.t(), Macro.t(), do: Macro.t()) :: Macro.t()
  defmacro defthen(step, context \\ @empty_context, do: block) do
    define_step(step, context, block)
  end

  defp define_step(step, context, block) do
    quoted_args = step |> Utils.extract_args() |> Enum.map(&arg_string_to_quoted_var/1)

    quote do
      defp unquote({:step, [], [Utils.normalise_name(step), quoted_args, context]}) do
        unquote(block)
      end
    end
  end

  defp valid_step?(step), do: step =~ ~r/^(Given|When|Then|And|But)\b/
  defp remove_keyword(step), do: String.replace(step, ~r/^\s*\S+\s+/, "")

  defp arg_string_to_quoted_var(arg) do
    quote do: var!(unquote({String.to_atom(arg), [], __MODULE__}))
  end
end
