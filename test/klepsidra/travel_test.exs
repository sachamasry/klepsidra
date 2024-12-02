defmodule Klepsidra.TravelTest do
  use Klepsidra.DataCase

  alias Klepsidra.Travel

  describe "trips" do
    alias Klepsidra.Travel.Trip

    import Klepsidra.TravelFixtures

    @invalid_attrs %{
      user_id: nil,
      country_id: nil,
      description: nil,
      entry_date: nil,
      entry_point: nil,
      exit_date: nil,
      exit_point: nil
    }

    # test "list_trips/0 returns all trips" do
    #   trip = trip_fixture()
    #   assert Travel.list_trips() == [trip]
    # end

    # test "get_trip!/1 returns the trip with given id" do
    #   trip = trip_fixture()
    #   assert Travel.get_trip!(trip.id) == trip
    # end

    # test "create_trip/1 with valid data creates a trip" do
    #   valid_attrs = %{
    #     id: "7488a646-e31f-11e4-aace-600308960662",
    #     user_id: "7488a646-e31f-11e4-aace-600308960662",
    #     country_id: "some country_id",
    #     entry_date: ~D[2024-11-29],
    #     entry_point: "Entry port",
    #     exit_date: ~D[2024-11-29],
    #     exit_point: "Exit point"
    #   }

    #   assert {:ok, %Trip{} = trip} = Travel.create_trip(valid_attrs)
    #   assert trip.id == "7488a646-e31f-11e4-aace-600308960662"
    #   assert trip.user_id == "7488a646-e31f-11e4-aace-600308960662"
    #   assert trip.country_id == "some country_id"
    #   assert trip.entry_date == ~D[2024-11-29]
    #   assert trip.exit_date == ~D[2024-11-29]
    # end

    # test "create_trip/1 with invalid data returns error changeset" do
    #   assert {:error, %Ecto.Changeset{}} = Travel.create_trip(@invalid_attrs)
    # end

    # test "update_trip/2 with valid data updates the trip" do
    #   trip = trip_fixture()

    #   update_attrs = %{
    #     id: "7488a646-e31f-11e4-aace-600308960668",
    #     user_id: "7488a646-e31f-11e4-aace-600308960668",
    #     country_id: "some updated country_id",
    #     entry_date: ~D[2024-11-30],
    #     entry_point: "Entry port",
    #     exit_date: ~D[2024-11-30],
    #     exit_point: "Exit point"
    #   }

    #   assert {:ok, %Trip{} = trip} = Travel.update_trip(trip, update_attrs)
    #   assert trip.id == "7488a646-e31f-11e4-aace-600308960668"
    #   assert trip.user_id == "7488a646-e31f-11e4-aace-600308960668"
    #   assert trip.country_id == "some updated country_id"
    #   assert trip.entry_date == ~D[2024-11-30]
    #   assert trip.exit_date == ~D[2024-11-30]
    # end

    # test "update_trip/2 with invalid data returns error changeset" do
    #   trip = trip_fixture()
    #   assert {:error, %Ecto.Changeset{}} = Travel.update_trip(trip, @invalid_attrs)
    #   assert trip == Travel.get_trip!(trip.id)
    # end

    # test "delete_trip/1 deletes the trip" do
    #   trip = trip_fixture()
    #   assert {:ok, %Trip{}} = Travel.delete_trip(trip)
    #   assert_raise Ecto.NoResultsError, fn -> Travel.get_trip!(trip.id) end
    # end

    # test "change_trip/1 returns a trip changeset" do
    #   trip = trip_fixture()
    #   assert %Ecto.Changeset{} = Travel.change_trip(trip)
    # end
  end
end
