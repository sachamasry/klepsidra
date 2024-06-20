defmodule Klepsidra.TimeTrackingTest do
  use Klepsidra.DataCase

  doctest Klepsidra.TimeTracking.Timer

  alias Klepsidra.TimeTracking

  describe "timers" do
    alias Klepsidra.TimeTracking.Timer

    import Klepsidra.TimeTrackingFixtures

    @invalid_attrs %{
      description: nil,
      start_stamp: nil,
      end_stamp: nil,
      duration: nil,
      duration_time_unit: nil,
      billing_duration: nil,
      billing_duration_time_unit: nil
    }

    test "list_timers/0 returns all timers" do
      timer = timer_fixture()
      assert TimeTracking.list_timers() == [timer]
    end

    test "get_timer!/1 returns the timer with given id" do
      timer = timer_fixture()
      assert TimeTracking.get_timer!(timer.id) == timer
    end

    test "create_timer/1 with valid data creates a timer" do
      valid_attrs = %{
        description: "some description",
        start_stamp: "2024-12-09 12:30",
        end_stamp: "2024-12-09 12:34:56",
        duration: 42,
        duration_time_unit: "some duration_time_unit",
        billing_duration: 42,
        billing_duration_time_unit: "some billing_duration_time_unit"
      }

      assert {:ok, %Timer{} = timer} = TimeTracking.create_timer(valid_attrs)
      assert timer.description == "some description"
      assert timer.start_stamp == "2024-12-09 12:30"
      assert timer.end_stamp == "2024-12-09 12:34:56"
      assert timer.duration == 42
      assert timer.duration_time_unit == "some duration_time_unit"
      assert timer.billing_duration == 42
      assert timer.billing_duration_time_unit == "some billing_duration_time_unit"
    end

    test "create_timer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TimeTracking.create_timer(@invalid_attrs)
    end

    test "update_timer/2 with valid data updates the timer" do
      timer = timer_fixture()

      update_attrs = %{
        description: "some updated description",
        start_stamp: "2024-12-09 12:30",
        end_stamp: "2024-12-09 12:34:56",
        duration: 43,
        duration_time_unit: "some updated duration_time_unit",
        billing_duration: 43,
        billing_duration_time_unit: "some updated billing_duration_time_unit"
      }

      assert {:ok, %Timer{} = timer} = TimeTracking.update_timer(timer, update_attrs)
      assert timer.description == "some updated description"
      assert timer.start_stamp == "2024-12-09 12:30"
      assert timer.end_stamp == "2024-12-09 12:34:56"
      assert timer.duration == 43
      assert timer.duration_time_unit == "some updated duration_time_unit"
      assert timer.billing_duration == 43
      assert timer.billing_duration_time_unit == "some updated billing_duration_time_unit"
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

  describe "notes" do
    alias Klepsidra.TimeTracking.Note

    import Klepsidra.TimeTrackingFixtures

    @invalid_attrs %{note: nil, user_id: nil}

    test "list_notes/0 returns all notes" do
      note = note_fixture()
      assert TimeTracking.list_notes() == [note]
    end

    test "get_note!/1 returns the note with given id" do
      note = note_fixture()
      assert TimeTracking.get_note!(note.id) == note
    end

    test "create_note/1 with valid data creates a note" do
      valid_attrs = %{note: "some note", user_id: 42}

      assert {:ok, %Note{} = note} = TimeTracking.create_note(valid_attrs)
      assert note.note == "some note"
      assert note.user_id == 42
    end

    test "create_note/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TimeTracking.create_note(@invalid_attrs)
    end

    test "update_note/2 with valid data updates the note" do
      note = note_fixture()
      update_attrs = %{note: "some updated note", user_id: 43}

      assert {:ok, %Note{} = note} = TimeTracking.update_note(note, update_attrs)
      assert note.note == "some updated note"
      assert note.user_id == 43
    end

    test "update_note/2 with invalid data returns error changeset" do
      note = note_fixture()
      assert {:error, %Ecto.Changeset{}} = TimeTracking.update_note(note, @invalid_attrs)
      assert note == TimeTracking.get_note!(note.id)
    end

    test "delete_note/1 deletes the note" do
      note = note_fixture()
      assert {:ok, %Note{}} = TimeTracking.delete_note(note)
      assert_raise Ecto.NoResultsError, fn -> TimeTracking.get_note!(note.id) end
    end

    test "change_note/1 returns a note changeset" do
      note = note_fixture()
      assert %Ecto.Changeset{} = TimeTracking.change_note(note)
    end
  end
end
