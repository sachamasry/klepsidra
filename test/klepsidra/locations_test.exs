defmodule Klepsidra.LocationsTest do
  use Klepsidra.DataCase

  alias Klepsidra.Locations

  # doctest Klepsidra.Locations

  describe "feature_codes" do
    alias Klepsidra.Locations.FeatureCode

    import Klepsidra.LocationsFixtures

    @invalid_attrs %{
      order: nil,
      description: nil,
      feature_class: nil,
      feature_code: nil,
      note: nil
    }

    test "list_feature_codes/0 returns all feature_codes" do
      feature_code = feature_code_fixture()
      assert Locations.list_feature_codes() == [feature_code]
    end

    test "get_feature_code!/2 returns the feature_code with given `feature_code`" do
      feature_code = feature_code_fixture()

      assert Locations.get_feature_code!(feature_code.feature_class, feature_code.feature_code) ==
               feature_code
    end

    test "create_feature_code/1 with valid data creates a feature_code" do
      valid_attrs = %{
        order: 42,
        description: "some description",
        feature_class: "P",
        feature_code: "PPL",
        note: "some note"
      }

      assert {:ok, %FeatureCode{} = feature_code} = Locations.create_feature_code(valid_attrs)
      assert feature_code.order == 42
      assert feature_code.description == "some description"
      assert feature_code.feature_class == "P"
      assert feature_code.feature_code == "PPL"
      assert feature_code.note == "some note"
    end

    test "create_feature_code/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Locations.create_feature_code(@invalid_attrs)
    end

    test "update_feature_code/2 with valid data updates the feature_code" do
      feature_code = feature_code_fixture()

      update_attrs = %{
        order: 43,
        description: "some updated description",
        feature_class: "P",
        feature_code: "PPLA",
        note: "some updated note"
      }

      assert {:ok, %FeatureCode{} = feature_code} =
               Locations.update_feature_code(feature_code, update_attrs)

      assert feature_code.order == 43
      assert feature_code.description == "some updated description"
      assert feature_code.feature_class == "P"
      assert feature_code.feature_code == "PPLA"
      assert feature_code.note == "some updated note"
    end

    test "update_feature_code/2 with invalid data returns error changeset" do
      feature_code = feature_code_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Locations.update_feature_code(feature_code, @invalid_attrs)

      assert feature_code ==
               Locations.get_feature_code!(feature_code.feature_class, feature_code.feature_code)
    end

    test "delete_feature_code/1 deletes the feature_code" do
      feature_code = feature_code_fixture()
      assert {:ok, %FeatureCode{}} = Locations.delete_feature_code(feature_code)

      assert Locations.get_feature_code!(feature_code.feature_class, feature_code.feature_code) ==
               nil
    end

    test "change_feature_code/1 returns a feature_code changeset" do
      feature_code = feature_code_fixture()
      assert %Ecto.Changeset{} = Locations.change_feature_code(feature_code)
    end
  end

  describe "cities" do
    alias Klepsidra.Locations.FeatureCode
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

    @valid_feature_code_attrs %{
      order: 42,
      description: "some description",
      feature_class: "P",
      feature_code: "PPLC",
      note: "some note"
    }

    # test "list_cities/0 returns all cities" do
    #   IO.inspect(Klepsidra.Locations.list_feature_codes())
    #   city = city_fixture()
    #   assert Locations.list_cities() == [city]
    # end

    # test "get_city!/1 returns the city with given id" do
    #   city = city_fixture()
    #   assert Locations.get_city!(city.id) == city
    # end

    # test "create_city/1 with valid data creates a city" do
    valid_city_attrs = %{
      name: "some name",
      geoname_id: 42,
      asciiname: "some asciiname",
      alternatenames: "some alternatenames",
      latitude: 120.5,
      longitude: 120.5,
      feature_class: "P",
      feature_code: "PPLC",
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

    #   assert {:ok, %FeatureCode{} = feature_code} =
    #          Locations.create_feature_code(@valid_feature_code_attrs)

    #   assert {:ok, %City{} = city} = Locations.create_city(valid_city_attrs)
    #   assert city.name == "some name"
    #   assert city.geoname_id == 42
    #   assert city.asciiname == "some asciiname"
    #   assert city.alternatenames == "some alternatenames"
    #   assert city.latitude == 120.5
    #   assert city.longitude == 120.5
    #   assert city.feature_class == "P"
    #   assert city.feature_code == "PPL"
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
    #   assert city.feature_class == "P"
    #   assert city.feature_code == "PPLA"
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
