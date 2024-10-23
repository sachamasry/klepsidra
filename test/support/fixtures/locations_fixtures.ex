defmodule Klepsidra.LocationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Klepsidra.Locations` context.
  """

  @doc """
  Generate a feature_class.
  """
  def feature_class_fixture(attrs \\ %{}) do
    {:ok, feature_class} =
      attrs
      |> Enum.into(%{
        description: "some description",
        feature_class: "P"
      })
      |> Klepsidra.Locations.create_feature_class()

    feature_class
  end

  @doc """
  Generate a feature_code.
  """
  def feature_code_fixture(attrs \\ %{}) do
    {:ok, feature_code} =
      attrs
      |> Enum.into(%{
        feature_code: "PPL",
        feature_class: "P",
        order: 42,
        description: "some description",
        note: "some note"
      })
      |> Klepsidra.Locations.create_feature_code()

    feature_code
  end

  @doc """
  Generate a continent.
  """
  def continent_fixture(attrs \\ %{}) do
    {:ok, continent} =
      attrs
      |> Enum.into(%{
        continent_code: "some continent_code",
        continent_name: "some continent_name",
        geoname_id: 42
      })
      |> Klepsidra.Locations.create_continent()

    continent
  end

  @doc """
  Generate a country.
  """
  def country_fixture(attrs \\ %{}) do
    {:ok, country} =
      attrs
      |> Enum.into(%{
        iso_country_code: "some iso",
        iso_3_country_code: "some iso_3",
        iso_numeric_country_code: 42,
        country_name: "some country_name",
        capital: "some capital",
        population: 42,
        area: 42,
        continent_code: "some continent",
        currency_code: "some currency_code",
        currency_name: "some currency_name",
        equivalent_fips_code: "some equivalent_fips_code",
        fips: "some fips",
        languages: "some languages",
        neighbours: "some neighbours",
        phone: "some phone",
        postal_code_format: "some postal_code_format",
        postal_code_regex: "some postal_code_regex",
        tld: "some tld",
        geoname_id: 42
      })
      |> Klepsidra.Locations.create_country()

    country
  end

  @doc """
  Generate a administrative_division1.
  """
  def administrative_division_1_fixture(attrs \\ %{}) do
    {:ok, administrative_division_1} =
      attrs
      |> Enum.into(%{
        administrative_division_1_code: "ENG",
        country_code: "GB",
        administrative_division_1_name: "some administrative_division_name",
        administrative_division_1_name_ascii: "some administrative_division_name_ascii",
        geoname_id: 42
      })
      |> Klepsidra.Locations.create_administrative_division_1()

    administrative_division_1
  end

  @doc """
  Generate a administrative_division2.
  """
  def administrative_division_2_fixture(attrs \\ %{}) do
    {:ok, administrative_division_2} =
      attrs
      |> Enum.into(%{
        administrative_division_2_code: "some administrative_division2_code",
        administrative_division_1_code: "some administrative_division1_code",
        country_code: "GB",
        administrative_division_2_ascii_name: "some administrative_division_ascii_name",
        administrative_division_2_name: "some administrative_division_name",
        geoname_id: 42
      })
      |> Klepsidra.Locations.create_administrative_division_2()

    administrative_division_2
  end

  @doc """
  Generate a city.
  """
  def city_fixture(attrs \\ %{}) do
    {:ok, city} =
      attrs
      |> Enum.into(%{
        geoname_id: 42,
        name: "some name",
        alternatenames: "some alternatenames",
        ascii_name: "some asciiname",
        country_code: "some country_code",
        cc2: "some cc2",
        feature_class: "P",
        feature_code: "PPL",
        latitude: 120.5,
        longitude: 120.5,
        administrative_division_1_code: "some admin1_code",
        administrative_division_2_code: "some admin2_code",
        administrative_division_3_code: "some admin3_code",
        administrative_division_4_code: "some admin4_code",
        population: 42,
        elevation: 42,
        dem: 42,
        timezone: "some timezone",
        modification_date: ~D[2024-10-08]
      })
      |> Klepsidra.Locations.create_city()

    city
  end
end
