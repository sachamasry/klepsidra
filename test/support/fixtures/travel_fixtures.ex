defmodule Klepsidra.TravelFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Klepsidra.Travel` context.
  """

  @doc """
  Generate a trip.
  """
  def trip_fixture(attrs \\ %{}) do
    {:ok, trip} =
      attrs
      |> Enum.into(%{
        user_id: "7488a646-e31f-11e4-aace-600308960662",
        country_id: "GBR",
        description: "Work-related trip",
        entry_date: ~D[2024-11-29],
        entry_point: "Entry into country",
        exit_date: ~D[2024-11-29],
        exit_point: "Exit from country"
      })
      |> Klepsidra.Travel.create_trip()

    trip
  end
end
