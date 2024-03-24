defmodule Klepsidra.TimeTrackingTest do
  use Klepsidra.DataCase

  doctest Klepsidra.TimeTracking.Timer

  alias Klepsidra.TimeTracking

  describe "timers" do
    alias Klepsidra.TimeTracking.Timer

    import Klepsidra.TimeTrackingFixtures

    @invalid_attrs %{description: nil, start_stamp: nil, end_stamp: nil, duration: nil, duration_time_unit: nil, reported_duration: nil, reported_duration_time_unit: nil}

    test "list_timers/0 returns all timers" do
      timer = timer_fixture()
      assert TimeTracking.list_timers() == [timer]
    end

    test "get_timer!/1 returns the timer with given id" do
      timer = timer_fixture()
      assert TimeTracking.get_timer!(timer.id) == timer
    end

    test "create_timer/1 with valid data creates a timer" do
      valid_attrs = %{description: "some description", start_stamp: "some start_stamp", end_stamp: "some end_stamp", duration: 42, duration_time_unit: "some duration_time_unit", reported_duration: 42, reported_duration_time_unit: "some reported_duration_time_unit"}

      assert {:ok, %Timer{} = timer} = TimeTracking.create_timer(valid_attrs)
      assert timer.description == "some description"
      assert timer.start_stamp == "some start_stamp"
      assert timer.end_stamp == "some end_stamp"
      assert timer.duration == 42
      assert timer.duration_time_unit == "some duration_time_unit"
      assert timer.reported_duration == 42
      assert timer.reported_duration_time_unit == "some reported_duration_time_unit"
    end

    test "create_timer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TimeTracking.create_timer(@invalid_attrs)
    end

    test "update_timer/2 with valid data updates the timer" do
      timer = timer_fixture()
      update_attrs = %{description: "some updated description", start_stamp: "some updated start_stamp", end_stamp: "some updated end_stamp", duration: 43, duration_time_unit: "some updated duration_time_unit", reported_duration: 43, reported_duration_time_unit: "some updated reported_duration_time_unit"}

      assert {:ok, %Timer{} = timer} = TimeTracking.update_timer(timer, update_attrs)
      assert timer.description == "some updated description"
      assert timer.start_stamp == "some updated start_stamp"
      assert timer.end_stamp == "some updated end_stamp"
      assert timer.duration == 43
      assert timer.duration_time_unit == "some updated duration_time_unit"
      assert timer.reported_duration == 43
      assert timer.reported_duration_time_unit == "some updated reported_duration_time_unit"
    end

    test "update_timer/2 with invalid data returns error changeset" do
      timer = timer_fixture()
      assert {:error, %Ecto.Changeset{}} = TimeTracking.update_timer(timer, @invalid_attrs)
      assert timer == TimeTracking.get_timer!(timer.id)
    end

    test "delete_timer/1 deletes the timer" do
      timer = timer_fixture()
      assert {:ok, %Timer{}} = TimeTracking.delete_timer(timer)
      assert_raise Ecto.NoResultsError, fn -> TimeTracking.get_timer!(timer.id) end
    end

    test "change_timer/1 returns a timer changeset" do
      timer = timer_fixture()
      assert %Ecto.Changeset{} = TimeTracking.change_timer(timer)
    end
  end
end
