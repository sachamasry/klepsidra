defmodule Klepsidra.LocationsTest do
  use Klepsidra.DataCase

  alias Klepsidra.Locations

  # doctest Klepsidra.Locations

  describe "feature_classes" do
    alias Klepsidra.Locations.FeatureClass

    import Klepsidra.LocationsFixtures

    @invalid_attrs %{
      order: nil,
      description: nil,
      feature_code: nil,
      feature_class: nil,
      note: nil
    }

    test "list_feature_classes/0 returns all feature_classes" do
      feature_class = feature_class_fixture()
      assert Locations.list_feature_classes() == [feature_class]
    end

    test "get_feature_class!/1 returns the feature_class with given `feature_class`" do
      feature_class = feature_class_fixture()
      assert Locations.get_feature_class!(feature_class.feature_class) == feature_class
    end

    test "create_feature_class/1 with valid data creates a feature_class" do
      valid_attrs = %{
        order: 42,
        description: "some description",
        feature_code: "P",
        feature_class: "PPL",
        note: "some note"
      }

      assert {:ok, %FeatureClass{} = feature_class} = Locations.create_feature_class(valid_attrs)
      assert feature_class.order == 42
      assert feature_class.description == "some description"
      assert feature_class.feature_code == "P"
      assert feature_class.feature_class == "PPL"
      assert feature_class.note == "some note"
    end

    test "create_feature_class/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Locations.create_feature_class(@invalid_attrs)
    end

    test "update_feature_class/2 with valid data updates the feature_class" do
      feature_class = feature_class_fixture()

      update_attrs = %{
        order: 43,
        description: "some updated description",
        feature_code: "P",
        feature_class: "PPLA",
        note: "some updated note"
      }

      assert {:ok, %FeatureClass{} = feature_class} =
               Locations.update_feature_class(feature_class, update_attrs)

      assert feature_class.order == 43
      assert feature_class.description == "some updated description"
      assert feature_class.feature_code == "P"
      assert feature_class.feature_class == "PPLA"
      assert feature_class.note == "some updated note"
    end

    test "update_feature_class/2 with invalid data returns error changeset" do
      feature_class = feature_class_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Locations.update_feature_class(feature_class, @invalid_attrs)

      assert feature_class == Locations.get_feature_class!(feature_class.feature_class)
    end

    test "delete_feature_class/1 deletes the feature_class" do
      feature_class = feature_class_fixture()
      assert {:ok, %FeatureClass{}} = Locations.delete_feature_class(feature_class)

      assert_raise Ecto.NoResultsError, fn ->
        Locations.get_feature_class!(feature_class.feature_class)
      end
    end

    test "change_feature_class/1 returns a feature_class changeset" do
      feature_class = feature_class_fixture()
      assert %Ecto.Changeset{} = Locations.change_feature_class(feature_class)
    end
  end

  describe "cities" do
    alias Klepsidra.Locations.FeatureClass
    alias Klepsidra.Locations.City

    import Klepsidra.LocationsFixtures

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

    @valid_feature_class_attrs %{
      order: 42,
      description: "some description",
      feature_code: "P",
      feature_class: "PPLC",
      note: "some note"
    }

    # test "list_cities/0 returns all cities" do
    #   city = city_fixture()
    #   assert Locations.list_cities() == [city]
    # end

    # test "get_city!/1 returns the city with given id" do
    #   city = city_fixture()
    #   assert Locations.get_city!(city.id) == city
    # end

    # test "create_city/1 with valid data creates a city" do
    #   valid_attrs = %{
    #     name: "some name",
    #     geoname_id: 42,
    #     asciiname: "some asciiname",
    #     alternatenames: "some alternatenames",
    #     latitude: 120.5,
    #     longitude: 120.5,
    #     feature_class: "P",
    #     feature_code: "PPLC",
    #     country_code: "some country_code",
    #     cc2: "some cc2",
    #     admin1_code: "some admin1_code",
    #     admin2_code: "some admin2_code",
    #     admin3_code: "some admin3_code",
    #     admin4_code: "some admin4_code",
    #     population: 42,
    #     elevation: 42,
    #     dem: 42,
    #     timezone: "some timezone",
    #     modification_date: ~D[2024-10-08]
    #   }

    #   assert {:ok, %FeatureClass{} = feature_class} =
    #          Locations.create_feature_class(@valid_feature_class_attrs)

    #   assert {:ok, %City{} = city} = Locations.create_city(valid_attrs)
    #   assert city.name == "some name"
    #   assert city.geoname_id == 42
    #   assert city.asciiname == "some asciiname"
    #   assert city.alternatenames == "some alternatenames"
    #   assert city.latitude == 120.5
    #   assert city.longitude == 120.5
    #   assert city.feature_class == "PPL"
    #   assert city.feature_code == "P"
    #   assert city.country_code == "some country_code"
    #   assert city.cc2 == "some cc2"
    #   assert city.admin1_code == "some admin1_code"
    #   assert city.admin2_code == "some admin2_code"
    #   assert city.admin3_code == "some admin3_code"
    #   assert city.admin4_code == "some admin4_code"
    #   assert city.population == 42
    #   assert city.elevation == 42
    #   assert city.dem == 42
    #   assert city.timezone == "some timezone"
    #   assert city.modification_date == ~D[2024-10-08]
    # end

    # test "create_city/1 with invalid data returns error changeset" do
    #   assert {:error, %Ecto.Changeset{}} = Locations.create_city(@invalid_attrs)
    # end

    # test "update_city/2 with valid data updates the city" do
    #   city = city_fixture()

    #   update_attrs = %{
    #     name: "some updated name",
    #     geoname_id: 43,
    #     asciiname: "some updated asciiname",
    #     alternatenames: "some updated alternatenames",
    #     latitude: 456.7,
    #     longitude: 456.7,
    #     feature_class: "P",
    #     feature_code: "PPLA",
    #     country_code: "some updated country_code",
    #     cc2: "some updated cc2",
    #     admin1_code: "some updated admin1_code",
    #     admin2_code: "some updated admin2_code",
    #     admin3_code: "some updated admin3_code",
    #     admin4_code: "some updated admin4_code",
    #     population: 43,
    #     elevation: 43,
    #     dem: 43,
    #     timezone: "some updated timezone",
    #     modification_date: ~D[2024-10-09]
    #   }

    #   assert {:ok, %City{} = city} = Locations.update_city(city, update_attrs)
    #   assert city.name == "some updated name"
    #   assert city.geoname_id == 43
    #   assert city.asciiname == "some updated asciiname"
    #   assert city.alternatenames == "some updated alternatenames"
    #   assert city.latitude == 456.7
    #   assert city.longitude == 456.7
    #   assert city.feature_class == "PPLA"
    #   assert city.feature_code == "P"
    #   assert city.country_code == "some updated country_code"
    #   assert city.cc2 == "some updated cc2"
    #   assert city.admin1_code == "some updated admin1_code"
    #   assert city.admin2_code == "some updated admin2_code"
    #   assert city.admin3_code == "some updated admin3_code"
    #   assert city.admin4_code == "some updated admin4_code"
    #   assert city.population == 43
    #   assert city.elevation == 43
    #   assert city.dem == 43
    #   assert city.timezone == "some updated timezone"
    #   assert city.modification_date == ~D[2024-10-09]
    # end

    # test "update_city/2 with invalid data returns error changeset" do
    #   city = city_fixture()
    #   assert {:error, %Ecto.Changeset{}} = Locations.update_city(city, @invalid_attrs)
    #   assert city == Locations.get_city!(city.id)
    # end

    # test "delete_city/1 deletes the city" do
    #   city = city_fixture()
    #   assert {:ok, %City{}} = Locations.delete_city(city)
    #   assert_raise Ecto.NoResultsError, fn -> Locations.get_city!(city.id) end
    # end

    # test "change_city/1 returns a city changeset" do
    #   city = city_fixture()
    #   assert %Ecto.Changeset{} = Locations.change_city(city)
    # end
  end
end
