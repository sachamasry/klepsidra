defmodule Klepsidra.TimeTrackingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Klepsidra.TimeTracking` context.
  """

  @doc """
  Generate a timer.
  """
  def timer_fixture(attrs \\ %{}) do
    {:ok, timer} =
      attrs
      |> Enum.into(%{
        description: "some description",
        duration: 42,
        duration_time_unit: "some duration_time_unit",
        end_stamp: "2024-12-09 12:34:56",
        billing_duration: 42,
        billing_duration_time_unit: "some billing_duration_time_unit",
        start_stamp: "2024-12-09 12:30"
      })
      |> Klepsidra.TimeTracking.create_timer()

    timer
  end

  @doc """
  Generate a note.
  """
  def note_fixture(attrs \\ %{}) do
    {:ok, note} =
      attrs
      |> Enum.into(%{
        note: "some note",
        user_id: 42
      })
      |> Klepsidra.TimeTracking.create_note()

    note
  end
end
