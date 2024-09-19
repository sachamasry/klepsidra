defmodule Klepsidra.TimeTracking.TimerTest do
  use ExUnit.Case
  # use Klepsidra.DataCase

  describe "Timers" do
    import Klepsidra.TimeTracking.Timer

    test "returns truthy or falsy answer to whether list is empty" do
      assert non_empty_list?([]) == nil
    end
  end
end
