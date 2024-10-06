defmodule Klepsidra.Utilities do
  @moduledoc """
  Utilities module defining commonly-used functionality all across the project.
  """

  use Private

  @doc """
  Calculates average duration, given a count and an aggregate duration.

  ## Comments

  As the functionality inevitably depends on division, eager pattern-matching
  is used in function heads, immediately returning zero, preventing divide by
  zero errors.

  ## Examples

      iex> Utilities.calculate_average_duration(13, Cldr.Unit.new!(1.857143, :second)) |> Cldr.Unit.round(1)
      Cldr.Unit.new!(:second, 7)

      iex> Utilities.calculate_average_duration(13, Cldr.Unit.new!(0, :second))
      0

      iex> Utilities.calculate_average_duration(13, 2)
      6

      iex> Utilities.calculate_average_duration(13, 0)
      0
  """
  @spec calculate_average_duration(
          count :: integer(),
          aggregate_duration :: Cldr.Unit.t()
        ) :: number()
  @spec calculate_average_duration(
          count :: integer(),
          aggregate_duration :: number() | any()
        ) :: number()
  def calculate_average_duration(_count, %Cldr.Unit{value: 0}), do: 0

  def calculate_average_duration(count, %Cldr.Unit{} = aggregate_duration)
      when is_integer(count) do
    duration_div(count, aggregate_duration.value)
    |> Cldr.Unit.new!(aggregate_duration.unit)
  end

  def calculate_average_duration(_count, 0), do: 0

  def calculate_average_duration(count, aggregate_duration)
      when is_integer(count) and is_number(aggregate_duration) do
    Kernel.div(count, aggregate_duration)
  end

  def calculate_average_duration(_count, _aggregate_duration), do: 0

  private do
    @spec duration_div(numerator :: number(), denominator :: number()) :: number()
    @spec duration_div(
            numerator :: number(),
            denominator :: integer() | Decimal.t()
          ) :: Decimal.t()
    def duration_div(numerator, %Decimal{} = denominator)
        when is_number(numerator) or is_struct(numerator, Decimal) do
      Decimal.div(numerator, denominator)
    end

    def duration_div(numerator, denominator)
        when is_number(numerator) and is_number(denominator) do
      Kernel.div(numerator, denominator)
    end
  end
end
