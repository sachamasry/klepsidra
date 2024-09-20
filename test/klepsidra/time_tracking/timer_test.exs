defmodule Klepsidra.TimeTracking.TimerTest do
  use ExUnit.Case
  # use Klepsidra.DataCase

  describe "Timers" do
    import Klepsidra.TimeTracking.Timer

    test "returns truthy or falsy answer to whether list is empty" do
      assert non_empty_list?([]) == nil
      assert non_empty_list?([Cldr.Unit.new!(:day, 1)]) == [Cldr.Unit.new!(:day, 1)]
      assert non_empty_list?([0, 1, 2]) == [0, 1, 2]
    end
  end
end
