defmodule Kale.Utils do
  @moduledoc """
  Utility functions, used by macros and the functions they create.
  """

  @doc """
  Remove interpolated variables from a step string, so that the call matches
  the definition.

  ```
  iex> Kale.Utils.normalise_name("I log on as {username}")
  "I log on as {}"

  iex> Kale.Utils.normalise_name("I log on as {fred}")
  "I log on as {}"
  ```
  """
  @spec normalise_name(String.t()) :: String.t()
  def normalise_name(step), do: String.replace(step, ~r/\{.*?\}/, "{}")

  @doc """
  Return the interpolated variables or argument names from a string. Elements
  in the returned list will always be strings.

  ```
  iex> Kale.Utils.extract_args("When I add {a} and{b}")
  ["a", "b"]

  iex> Kale.Utils.extract_args("When I add {1} and{2}")
  ["1", "2"]
  """
  @spec extract_args(String.t()) :: [String.t()]
  def extract_args(step) do
    ~r/\{(.*?)\}/ |> Regex.scan(step, capture: :all_but_first) |> List.flatten()
  end
end
