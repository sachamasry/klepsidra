defmodule Klepsidra.UtilitiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Klepsidra.Utilities` context.
  """

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
        feature_class: "some feature_class",
        feature_code: "some feature_code",
        geoname_id: 42,
        latitude: 120.5,
        longitude: 120.5,
        modification_date: ~D[2024-10-08],
        name: "some name",
        population: 42,
        timezone: "some timezone"
      })
      |> Klepsidra.Utilities.create_city()

    city
  end
end
