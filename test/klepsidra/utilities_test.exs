defmodule Klepsidra.UtilitiesTest do
  use Klepsidra.DataCase

  alias Klepsidra.Utilities

  # doctest Klepsidra.Utilities

  describe "cities" do
    alias Klepsidra.Utilities.City

    import Klepsidra.UtilitiesFixtures

    @invalid_attrs %{
      name: nil,
      geoname_id: nil,
      asciiname: nil,
      alternatenames: nil,
      latitude: nil,
      longitude: nil,
      feature_class: nil,
      feature_code: nil,
      country_code: nil,
      cc2: nil,
      admin1_code: nil,
      admin2_code: nil,
      admin3_code: nil,
      admin4_code: nil,
      population: nil,
      elevation: nil,
      dem: nil,
      timezone: nil,
      modification_date: nil
    }

    test "list_cities/0 returns all cities" do
      city = city_fixture()
      assert Utilities.list_cities() == [city]
    end

    test "get_city!/1 returns the city with given id" do
      city = city_fixture()
      assert Utilities.get_city!(city.id) == city
    end

    test "create_city/1 with valid data creates a city" do
      valid_attrs = %{
        name: "some name",
        geoname_id: 42,
        asciiname: "some asciiname",
        alternatenames: "some alternatenames",
        latitude: 120.5,
        longitude: 120.5,
        feature_class: "some feature_class",
        feature_code: "some feature_code",
        country_code: "some country_code",
        cc2: "some cc2",
        admin1_code: "some admin1_code",
        admin2_code: "some admin2_code",
        admin3_code: "some admin3_code",
        admin4_code: "some admin4_code",
        population: 42,
        elevation: 42,
        dem: 42,
        timezone: "some timezone",
        modification_date: ~D[2024-10-08]
      }

      assert {:ok, %City{} = city} = Utilities.create_city(valid_attrs)
      assert city.name == "some name"
      assert city.geoname_id == 42
      assert city.asciiname == "some asciiname"
      assert city.alternatenames == "some alternatenames"
      assert city.latitude == 120.5
      assert city.longitude == 120.5
      assert city.feature_class == "some feature_class"
      assert city.feature_code == "some feature_code"
      assert city.country_code == "some country_code"
      assert city.cc2 == "some cc2"
      assert city.admin1_code == "some admin1_code"
      assert city.admin2_code == "some admin2_code"
      assert city.admin3_code == "some admin3_code"
      assert city.admin4_code == "some admin4_code"
      assert city.population == 42
      assert city.elevation == 42
      assert city.dem == 42
      assert city.timezone == "some timezone"
      assert city.modification_date == ~D[2024-10-08]
    end

    test "create_city/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Utilities.create_city(@invalid_attrs)
    end

    test "update_city/2 with valid data updates the city" do
      city = city_fixture()

      update_attrs = %{
        name: "some updated name",
        geoname_id: 43,
        asciiname: "some updated asciiname",
        alternatenames: "some updated alternatenames",
        latitude: 456.7,
        longitude: 456.7,
        feature_class: "some updated feature_class",
        feature_code: "some updated feature_code",
        country_code: "some updated country_code",
        cc2: "some updated cc2",
        admin1_code: "some updated admin1_code",
        admin2_code: "some updated admin2_code",
        admin3_code: "some updated admin3_code",
        admin4_code: "some updated admin4_code",
        population: 43,
        elevation: 43,
        dem: 43,
        timezone: "some updated timezone",
        modification_date: ~D[2024-10-09]
      }

      assert {:ok, %City{} = city} = Utilities.update_city(city, update_attrs)
      assert city.name == "some updated name"
      assert city.geoname_id == 43
      assert city.asciiname == "some updated asciiname"
      assert city.alternatenames == "some updated alternatenames"
      assert city.latitude == 456.7
      assert city.longitude == 456.7
      assert city.feature_class == "some updated feature_class"
      assert city.feature_code == "some updated feature_code"
      assert city.country_code == "some updated country_code"
      assert city.cc2 == "some updated cc2"
      assert city.admin1_code == "some updated admin1_code"
      assert city.admin2_code == "some updated admin2_code"
      assert city.admin3_code == "some updated admin3_code"
      assert city.admin4_code == "some updated admin4_code"
      assert city.population == 43
      assert city.elevation == 43
      assert city.dem == 43
      assert city.timezone == "some updated timezone"
      assert city.modification_date == ~D[2024-10-09]
    end

    test "update_city/2 with invalid data returns error changeset" do
      city = city_fixture()
      assert {:error, %Ecto.Changeset{}} = Utilities.update_city(city, @invalid_attrs)
      assert city == Utilities.get_city!(city.id)
    end

    test "delete_city/1 deletes the city" do
      city = city_fixture()
      assert {:ok, %City{}} = Utilities.delete_city(city)
      assert_raise Ecto.NoResultsError, fn -> Utilities.get_city!(city.id) end
    end

    test "change_city/1 returns a city changeset" do
      city = city_fixture()
      assert %Ecto.Changeset{} = Utilities.change_city(city)
    end
  end
end
