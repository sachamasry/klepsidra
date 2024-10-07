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

  As the functionality inevitably depends on division, eager pattern-matching
  is used in function heads, immediately returning zero, preventing divide by
  zero errors.

  ## Arguments

  * `sum` is any valid `Cldr.Unit`, integer or float, and is the numerator
  * `count` is an integer only, used for a discrete number of events

  ## Returns

  * The arithmetic mean, in integer or float format

  ## Examples

      iex> Math.arithmetic_mean(Cldr.Unit.new!(91.0, :second), 13)
      Cldr.Unit.new!(:second, 7)

      iex> Math.arithmetic_mean(Cldr.Unit.new!(0, :second), 13)
      Cldr.Unit.new!(:second, 0)

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
  def arithmetic_mean(%Cldr.Unit{} = _sum, 0), do: 0
  def arithmetic_mean(_sum, 0), do: 0

  def arithmetic_mean(%Cldr.Unit{} = sum, count)
      when is_integer(count) do
    multi_unit_div(sum, count)
  end

  def arithmetic_mean(sum, count)
      when is_number(sum) and is_integer(count) do
    multi_unit_div(sum, count)
  end

  @doc """
  Divides multiple types of units not directly covered in the `Kernel`,
  `Decimal` and `Cldr.Unit` modules.

  As division by zero is illegal, eager pattern-matching is used in
  function heads, immediately returning zero or equivalent, preventing 
  raising of errors.

  ## Arguments

  * `numerator`, which is a number, `Decimal`, or `Cldr.Unit` type
  * `denominator`, a number or `Decimal` type

  ## Returns

  * Result of the division, in float, `Decimal`, or `Cldr.Unit` type

  ## Examples

      iex> Math.multi_unit_div(300, 13)
      23.076923076923077
  """
  @spec multi_unit_div(
          numerator :: number() | Decimal.t() | Cldr.Unit.t(),
          denominator :: number() | Decimal.t()
        ) :: float() | Decimal.t() | Cldr.Unit.t()
  def multi_unit_div(%Decimal{} = _numerator, 0), do: Decimal.new(0)
  def multi_unit_div(%Decimal{} = _numerator, +0.0), do: Decimal.new("0.0")
  def multi_unit_div(_numerator, %Decimal{coef: 0}), do: Decimal.new(0)
  def multi_unit_div(_numerator, 0), do: 0.0
  def multi_unit_div(_numerator, +0.0), do: 0.0

  def multi_unit_div(%Cldr.Unit{} = numerator, denominator)
      when is_integer(denominator) or is_struct(denominator, Cldr.Unit) do
    Cldr.Unit.div!(numerator, denominator)
  end

  def multi_unit_div(%Decimal{} = numerator, denominator)
      when is_float(denominator) do
    Decimal.div(numerator, Decimal.from_float(denominator))
  end

  def multi_unit_div(%Decimal{} = numerator, denominator)
      when is_integer(denominator) do
    Decimal.div(numerator, denominator)
  end

  def multi_unit_div(numerator, %Decimal{} = denominator)
      when is_float(numerator) do
    Decimal.div(Decimal.from_float(numerator), denominator)
  end

  def multi_unit_div(numerator, %Decimal{} = denominator)
      when is_integer(numerator) do
    Decimal.div(numerator, denominator)
  end

  def multi_unit_div(numerator, denominator)
      when is_number(numerator) and is_number(denominator) do
    Kernel./(numerator, denominator)
  end
end
