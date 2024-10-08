defmodule Klepsidra.MathTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Klepsidra.Math

  doctest Klepsidra.Math

  describe "arithmetic mean calculations: `Math.arithmetic_mean/2`" do
    test "calculate arithmetic mean between `Cldr.Unit` sum and integer count" do
      assert Math.arithmetic_mean(Cldr.Unit.new!(3600, :second), 12).value == 300.0
    end

    test "calculate arithmetic mean between zero `Cldr.Unit` sum and integer count" do
      assert Math.arithmetic_mean(Cldr.Unit.new!(0, :second), 12).value == 0
    end

    test "calculate arithmetic mean between `Cldr.Unit` sum and integer zero count" do
      assert Math.arithmetic_mean(Cldr.Unit.new!(3600, :second), 0) == 0
    end

    test "calculate arithmetic mean between integer sum and integer count" do
      assert Math.arithmetic_mean(36, 12) == 3.0
    end

    test "calculate arithmetic mean between integer sum and integer zero count" do
      assert Math.arithmetic_mean(36, 0) == 0
    end

    test "calculate arithmetic mean between float sum and integer count" do
      assert Math.arithmetic_mean(36.63, 12) == 3.0525
    end

    test "calculate arithmetic mean between float sum and integer zero count" do
      assert Math.arithmetic_mean(36.63, 0) == 0
    end

    property "checks identity and zero properties with Cldr.Unit numerator" do
      check all(numerator <- integer(), numerator >= 0) do
        unit_numerator = Cldr.Unit.new!(numerator, :second)

        assert Math.arithmetic_mean(unit_numerator, 1) == unit_numerator
        assert Math.arithmetic_mean(unit_numerator, 0) == 0
      end
    end
  end

  describe "multi-unit division: `Math.multi_unit_div/2`" do
    test "divide integer with float" do
      assert Math.multi_unit_div(13, 2.6) == 5.0
    end

    test "divides integer with integer" do
      assert Math.multi_unit_div(42, 3) == 14.0
    end

    test "divide integer with zero" do
      assert Math.multi_unit_div(42, 0) == 0.0
      assert Math.multi_unit_div(42, 0.0) == 0.0
    end

    test "divide float with float" do
      assert Math.multi_unit_div(42.12, 3.6) == 11.7
    end

    test "divide float with integer" do
      assert Math.multi_unit_div(42.12, 3) == 14.04
    end

    test "divide float with zero" do
      assert Math.multi_unit_div(42.13, 0) == 0.0
      assert Math.multi_unit_div(42.13, 0.0) == 0.0
    end

    test "divide decimal with float" do
      assert Math.multi_unit_div(Decimal.new(13), 2.6) == Decimal.new("5")
    end

    test "divides decimal with integer" do
      assert Math.multi_unit_div(Decimal.new(42), 3) == Decimal.new("14")
    end

    test "divide decimal with zero" do
      assert Math.multi_unit_div(Decimal.new(42), 0) == Decimal.new(0)
      assert Math.multi_unit_div(Decimal.new(42), 0.0) == Decimal.new("0.0")
    end

    test "divide integer with decimal float" do
      assert Math.multi_unit_div(13, Decimal.new("2.6")) == Decimal.new("5")
    end

    test "divides integer with decimal integer" do
      assert Math.multi_unit_div(42, Decimal.new(3)) == Decimal.new("14")
    end

    test "divide integer with decimal zero" do
      assert Math.multi_unit_div(42, Decimal.new(0)) == Decimal.new(0)
      assert Math.multi_unit_div(42, Decimal.new("0.0")) == Decimal.new(0)
    end

    test "divide float with decimal float" do
      assert Math.multi_unit_div(42.12, Decimal.new("3.6")) == Decimal.new("11.7")
    end

    test "divide float with decimal integer" do
      assert Math.multi_unit_div(42.12, Decimal.new(3)) == Decimal.new("14.04")
    end

    test "divide float with decimal zero" do
      assert Math.multi_unit_div(42.13, Decimal.new(0)) == Decimal.new(0)
      assert Math.multi_unit_div(42.13, Decimal.new("0.0")) == Decimal.new(0)
    end

    property "checks `multi_unit_div/2` identity and zero properties with integer numerator" do
      check all(numerator <- integer()) do
        decimal_numerator = Decimal.new(numerator)
        assert Math.multi_unit_div(numerator, 1) == numerator
        assert Math.multi_unit_div(numerator, 1.0) == numerator
        assert Math.multi_unit_div(numerator, 0) == 0
        assert Math.multi_unit_div(numerator, 0.0) == 0
        assert Math.multi_unit_div(decimal_numerator, 1) == decimal_numerator

        assert Decimal.eq?(
                 Math.multi_unit_div(decimal_numerator, 1.0),
                 decimal_numerator
               )

        assert Decimal.eq?(
                 Math.multi_unit_div(decimal_numerator, 0),
                 0
               )

        assert Decimal.eq?(
                 Math.multi_unit_div(decimal_numerator, 0.0),
                 0
               )
      end
    end

    property "checks `multi_unit_div/2` identity and zero properties with float numerator" do
      check all(numerator <- float()) do
        decimal_numerator = Decimal.from_float(numerator)
        assert Math.multi_unit_div(numerator, 1) == numerator
        assert Math.multi_unit_div(numerator, 1.0) == numerator
        assert Math.multi_unit_div(numerator, 0) == 0
        assert Math.multi_unit_div(numerator, 0.0) == 0

        assert Decimal.eq?(
                 Math.multi_unit_div(decimal_numerator, 1),
                 Decimal.new("#{numerator}")
               )

        assert Decimal.eq?(
                 Math.multi_unit_div(decimal_numerator, 1.0),
                 Decimal.new("#{numerator}")
               )

        assert Decimal.eq?(
                 Math.multi_unit_div(decimal_numerator, 0),
                 0
               )

        assert Decimal.eq?(
                 Math.multi_unit_div(decimal_numerator, 0.0),
                 0
               )
      end
    end
  end
end
