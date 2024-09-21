defmodule Klepsidra.TimeTracking.TimerTest do
  use ExUnit.Case
  # use Klepsidra.DataCase

  describe "Timers" do
    import Klepsidra.TimeTracking.Timer

    test "test removal of restricted units from decomposed unit" do
      assert adjust_for_restricted_subunits(
               (24 * 60 * 60 + 1.75 * 60 * 60)
               |> Cldr.Unit.new!(:second)
               |> Cldr.Unit.decompose([:day, :hour_increment, :minute_increment]),
               [:day, :hour_increment, :minute_increment]
             ) == nil

      assert adjust_for_restricted_subunits(
               (24 * 60 * 60 + 1.75 * 60 * 60)
               |> Cldr.Unit.new!(:second)
               |> Cldr.Unit.decompose([:day, :hour_increment, :minute_increment]),
               [:day, :hour_increment]
             ) == [Cldr.Unit.new!(:minute_increment, "45.0000000000000480")]

      assert adjust_for_restricted_subunits(
               (23 * 60 * 60)
               |> Cldr.Unit.new!(:second)
               |> Cldr.Unit.decompose([:day, :hour_increment]),
               [:hour_increment]
             ) == nil
    end

    test "returns truthy or falsy answer to whether provided list is empty" do
      assert non_empty_list?([]) == nil
      assert non_empty_list?([Cldr.Unit.new!(:day, 1)]) == [Cldr.Unit.new!(:day, 1)]
      assert non_empty_list?([0, 1, 2]) == [0, 1, 2]
    end
  end
end
