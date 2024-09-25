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
        duration_time_unit: "minute",
        end_stamp: "2024-12-09 12:34:56",
        billing_duration: 42,
        billing_duration_time_unit: "minute",
        start_stamp: "2024-12-09 12:30",
        billing_rate: "0"
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
        note: "some note"
      })
      |> Klepsidra.TimeTracking.create_note()

    note
  end

  @doc """
  Generate a activity_type.
  """
  def activity_type_fixture(attrs \\ %{}) do
    {:ok, activity_type} =
      attrs
      |> Enum.into(%{
        active: true,
        name: "some activity_type",
        billing_rate: "120.5"
      })
      |> Klepsidra.TimeTracking.create_activity_type()

    activity_type
  end
end
