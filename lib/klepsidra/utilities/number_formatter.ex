defmodule Klepsidra.Utilities.NumberFormatter do
  @moduledoc """
  This module handles number formatting for human consumption, or converting
  numbers into clean and commonly expected representations.
  """

  @doc """
  Formats numbers for human-friendly display with intelligent precision.
  For example, whole numbers (integers) should print as they are;
  floating-point numbers should print up to a precision of a maximum
  number of decimal places; and floating-point numbers which are
  essentially whole should print as the whole number, with no trailing
  decimal places.

  ## Examples
      iex> NumberFormatter.human_format(1)
      "1"
      iex> NumberFormatter.human_format(3.14)
      "3.14"
      iex> NumberFormatter.human_format(10.0)
      "10"
      iex> NumberFormatter.human_format(1.23)
      "1.23"
  """
  @spec human_format(number :: integer() | float() | Decimal.t()) :: String.t()
  def human_format(number) when is_integer(number) do
    Integer.to_string(number)
  end

  def human_format(number) when is_float(number) do
    Float.to_string(number)
    |> String.trim_trailing("0")
    |> String.trim_trailing(".")
  end

  def human_format(number) when is_struct(number, Decimal) do
    Decimal.to_string(number)
    |> String.trim_trailing("0")
    |> String.trim_trailing(".")
  end
end
