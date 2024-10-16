defmodule Klepsidra.LocationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Klepsidra.Locations` context.
  """

  @doc """
  Generate a feature_code.
  """
  def feature_code_fixture(attrs \\ %{}) do
    {:ok, feature_code} =
      attrs
      |> Enum.into(%{
        description: "some description",
        feature_class: "P",
        feature_code: "PPL",
        note: "some note",
        order: 42
      })
      |> Klepsidra.Locations.create_feature_code()

    feature_code
  end

  @doc """
  Generate a city.
  """
  def city_fixture(attrs \\ %{}) do
    {:ok, city} =
      attrs
      |> Enum.into(%{
        admin1_code: "some admin1_code",
        admin2_code: "some admin2_code",
        admin3_code: "some admin3_code",
        admin4_code: "some admin4_code",
        alternatenames: "some alternatenames",
        asciiname: "some asciiname",
        cc2: "some cc2",
        country_code: "some country_code",
        dem: 42,
        elevation: 42,
        feature_class: "P",
        feature_code: "PPL",
        geoname_id: 42,
        latitude: 120.5,
        longitude: 120.5,
        modification_date: ~D[2024-10-08],
        name: "some name",
        population: 42,
        timezone: "some timezone"
      })
      |> Klepsidra.Locations.create_city()

    city
  end
end
