defmodule Klepsidra.Math do
  @moduledoc """
  Utilities module defining mathematical functionality, commonly used
  all across the project.

  This is a supplement to the inbuilt maths fuctions
  in the `Kernel` module, but also `Decimal` and `Cldr.Unit.Math`,
  providing highly specialised functions, working across a range of used
  units.
  """

  use Private

  @doc """
  Calculates the arithmetic mean, usually referred to as the average,
  given a sum and count of items.

  ## Comments

  As the functionality inevitably depends on division, eager pattern-matching
  is used in function heads, immediately returning zero, preventing divide by
  zero errors.

  ## Examples

      iex> Math.arithmetic_mean(Cldr.Unit.new!(91.0, :second), 13)
      Cldr.Unit.new!(:second, 7.0)

      iex> Math.arithmetic_mean(Cldr.Unit.new!(0, :second), 13)
      Cldr.Unit.new!(:second, "0.0")

      iex> Math.arithmetic_mean(Cldr.Unit.new!(7, :second), 0)
      0

      iex> Math.arithmetic_mean(13, 2)
      6.5

      iex> Math.arithmetic_mean(13, 0)
      0
  """
  @spec arithmetic_mean(
          sum :: Cldr.Unit.t(),
          count :: integer()
        ) :: number()
  @spec arithmetic_mean(
          sum :: number() | any(),
          count :: integer()
        ) :: number()
  def arithmetic_mean(_sum, 0), do: 0

  def arithmetic_mean(%Cldr.Unit{} = sum, count)
      when is_integer(count) do
    multi_unit_div(sum.value, count)
    |> Cldr.Unit.new!(sum.unit)
  end

  def arithmetic_mean(sum, count)
      when is_number(count) and is_integer(sum) do
    multi_unit_div(sum, count)
  end

  @spec multi_unit_div(
          numerator :: number() | Decimal.t(),
          denominator :: number() | Decimal.t()
        ) :: float() | Decimal.t()
  def multi_unit_div(_numerator, 0), do: 0

  def multi_unit_div(%Decimal{} = numerator, denominator)
      when is_number(denominator) do
    Decimal.div(numerator, denominator)
  end

  def multi_unit_div(numerator, %Decimal{} = denominator)
      when is_number(numerator) do
    Decimal.div(numerator, denominator)
  end

  def multi_unit_div(numerator, denominator)
      when is_number(numerator) and is_number(denominator) do
    Kernel./(numerator, denominator)
  end
end
