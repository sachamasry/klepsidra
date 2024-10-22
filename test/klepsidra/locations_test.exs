defmodule Klepsidra.LocationsTest do
  use Klepsidra.DataCase

  alias Klepsidra.Locations

  # doctest Klepsidra.Locations

  describe "locations_feature_classes" do
    alias Klepsidra.Locations.FeatureClass

    import Klepsidra.LocationsFixtures

    @invalid_attrs %{description: nil, feature_class: nil}

    test "list_feature_classes/0 returns all locations_feature_classes" do
      feature_class = feature_class_fixture()
      assert Locations.list_feature_classes() == [feature_class]
    end

    test "get_feature_class!/1 returns the feature_class with given `feature_class`" do
      feature_class = feature_class_fixture()
      assert Locations.get_feature_class!(feature_class.feature_class) == feature_class
    end

    test "create_feature_class/1 with valid data creates a feature_class" do
      valid_attrs = %{description: "some description", feature_class: "some feature_class"}

      assert {:ok, %FeatureClass{} = feature_class} = Locations.create_feature_class(valid_attrs)
      assert feature_class.description == "some description"
      assert feature_class.feature_class == "some feature_class"
    end

    test "create_feature_class/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Locations.create_feature_class(@invalid_attrs)
    end

    test "update_feature_class/2 with valid data updates the feature_class" do
      feature_class = feature_class_fixture()

      update_attrs = %{
        description: "some updated description",
        feature_class: "some updated feature_class"
      }

      assert {:ok, %FeatureClass{} = feature_class} =
               Locations.update_feature_class(feature_class, update_attrs)

      assert feature_class.description == "some updated description"
      assert feature_class.feature_class == "some updated feature_class"
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

      assert Locations.get_feature_class!(feature_class.feature_class) == nil
    end

    test "change_feature_class/1 returns a feature_class changeset" do
      feature_class = feature_class_fixture()
      assert %Ecto.Changeset{} = Locations.change_feature_class(feature_class)
    end
  end

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

    # test "list_feature_codes/0 returns all feature_codes" do
    #   feature_code = feature_code_fixture()
    #   assert Locations.list_feature_codes() == [feature_code]
    # end

    # test "get_feature_code!/2 returns the feature_code with given `feature_code`" do
    #   feature_code = feature_code_fixture()

    #   assert Locations.get_feature_code!(feature_code.feature_class, feature_code.feature_code) ==
    #            feature_code
    # end

    # test "create_feature_code/1 with valid data creates a feature_code" do
    #   valid_attrs = %{
    #     order: 42,
    #     description: "some description",
    #     feature_class: "P",
    #     feature_code: "PPL",
    #     note: "some note"
    #   }

    #   assert {:ok, %FeatureCode{} = feature_code} = Locations.create_feature_code(valid_attrs)
    #   assert feature_code.order == 42
    #   assert feature_code.description == "some description"
    #   assert feature_code.feature_class == "P"
    #   assert feature_code.feature_code == "PPL"
    #   assert feature_code.note == "some note"
    # end

    # test "create_feature_code/1 with invalid data returns error changeset" do
    #   assert {:error, %Ecto.Changeset{}} = Locations.create_feature_code(@invalid_attrs)
    # end

    # test "update_feature_code/2 with valid data updates the feature_code" do
    #   feature_code = feature_code_fixture()

    #   update_attrs = %{
    #     order: 43,
    #     description: "some updated description",
    #     feature_class: "P",
    #     feature_code: "PPLA",
    #     note: "some updated note"
    #   }

    #   assert {:ok, %FeatureCode{} = feature_code} =
    #            Locations.update_feature_code(feature_code, update_attrs)

    #   assert feature_code.order == 43
    #   assert feature_code.description == "some updated description"
    #   assert feature_code.feature_class == "P"
    #   assert feature_code.feature_code == "PPLA"
    #   assert feature_code.note == "some updated note"
    # end

    # test "update_feature_code/2 with invalid data returns error changeset" do
    #   feature_code = feature_code_fixture()

    #   assert {:error, %Ecto.Changeset{}} =
    #            Locations.update_feature_code(feature_code, @invalid_attrs)

    #   assert feature_code ==
    #            Locations.get_feature_code!(feature_code.feature_class, feature_code.feature_code)
    # end

    # test "delete_feature_code/1 deletes the feature_code" do
    #   feature_code = feature_code_fixture()
    #   assert {:ok, %FeatureCode{}} = Locations.delete_feature_code(feature_code)

    #   assert Locations.get_feature_code!(feature_code.feature_class, feature_code.feature_code) ==
    #            nil
    # end

    # test "change_feature_code/1 returns a feature_code changeset" do
    #   feature_code = feature_code_fixture()
    #   assert %Ecto.Changeset{} = Locations.change_feature_code(feature_code)
    # end
  end

  describe "locations_continents" do
    alias Klepsidra.Locations.Continent

    import Klepsidra.LocationsFixtures

    @invalid_attrs %{continent_code: nil, continent_name: nil, geoname_id: nil}

    test "list_continents/0 returns all locations_continents" do
      continent = continent_fixture()
      assert Locations.list_continents() == [continent]
    end

    test "get_continent!/1 returns the continent with given id" do
      continent = continent_fixture()
      assert Locations.get_continent!(continent.continent_code) == continent
    end

    test "create_continent/1 with valid data creates a continent" do
      valid_attrs = %{
        continent_code: "some continent_code",
        continent_name: "some continent_name",
        geoname_id: 42
      }

      assert {:ok, %Continent{} = continent} = Locations.create_continent(valid_attrs)
      assert continent.continent_code == "some continent_code"
      assert continent.continent_name == "some continent_name"
      assert continent.geoname_id == 42
    end

    test "create_continent/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Locations.create_continent(@invalid_attrs)
    end

    test "update_continent/2 with valid data updates the continent" do
      continent = continent_fixture()

      update_attrs = %{
        continent_code: "some updated continent_code",
        continent_name: "some updated continent_name",
        geoname_id: 43
      }

      assert {:ok, %Continent{} = continent} = Locations.update_continent(continent, update_attrs)
      assert continent.continent_code == "some updated continent_code"
      assert continent.continent_name == "some updated continent_name"
      assert continent.geoname_id == 43
    end

    test "update_continent/2 with invalid data returns error changeset" do
      continent = continent_fixture()
      assert {:error, %Ecto.Changeset{}} = Locations.update_continent(continent, @invalid_attrs)
      assert continent == Locations.get_continent!(continent.continent_code)
    end

    test "delete_continent/1 deletes the continent" do
      continent = continent_fixture()
      assert {:ok, %Continent{}} = Locations.delete_continent(continent)

      assert Locations.get_continent!(continent.continent_code) == nil
    end

    test "change_continent/1 returns a continent changeset" do
      continent = continent_fixture()
      assert %Ecto.Changeset{} = Locations.change_continent(continent)
    end
  end

  describe "countries" do
    alias Klepsidra.Locations.Country

    import Klepsidra.LocationsFixtures

    @invalid_attrs %{
      neighbours: nil,
      iso: nil,
      iso_3: nil,
      iso_numeric: nil,
      fips: nil,
      country_name: nil,
      capital: nil,
      area: nil,
      population: nil,
      continent_code: nil,
      tld: nil,
      currency_code: nil,
      currency_name: nil,
      phone: nil,
      postal_code_format: nil,
      postal_code_regex: nil,
      languages: nil,
      geoname_id: nil,
      equivalent_fips_code: nil
    }

    # test "list_countries/0 returns all countries" do
    #   country = country_fixture()
    #   assert Locations.list_countries() == [country]
    # end

    # test "get_country!/1 returns the country with given id" do
    #   country = country_fixture()
    #   assert Locations.get_country!(country.iso) == country
    # end

    # test "create_country/1 with valid data creates a country" do
    #   valid_attrs = %{
    #     neighbours: "some neighbours",
    #     iso: "some iso",
    #     iso_3: "some iso_3",
    #     iso_numeric: 42,
    #     fips: "some fips",
    #     country_name: "some country_name",
    #     capital: "some capital",
    #     area: 42,
    #     population: 42,
    #     continent_code: "some continent",
    #     tld: "some tld",
    #     currency_code: "some currency_code",
    #     currency_name: "some currency_name",
    #     phone: "some phone",
    #     postal_code_format: "some postal_code_format",
    #     postal_code_regex: "some postal_code_regex",
    #     languages: "some languages",
    #     geoname_id: 123,
    #     equivalent_fips_code: "some equivalent_fips_code"
    #   }

    #   assert {:ok, %Country{} = country} = Locations.create_country(valid_attrs)
    #   assert country.neighbours == "some neighbours"
    #   assert country.iso == "some iso"
    #   assert country.iso_3 == "some iso_3"
    #   assert country.iso_numeric == 42
    #   assert country.fips == "some fips"
    #   assert country.country_name == "some country_name"
    #   assert country.capital == "some capital"
    #   assert country.area == 42
    #   assert country.population == 42
    #   assert country.continent_code == "some continent"
    #   assert country.tld == "some tld"
    #   assert country.currency_code == "some currency_code"
    #   assert country.currency_name == "some currency_name"
    #   assert country.phone == "some phone"
    #   assert country.postal_code_format == "some postal_code_format"
    #   assert country.postal_code_regex == "some postal_code_regex"
    #   assert country.languages == "some languages"
    #   assert country.geoname_id == 123
    #   assert country.equivalent_fips_code == "some equivalent_fips_code"
    # end

    # test "create_country/1 with invalid data returns error changeset" do
    #   assert {:error, %Ecto.Changeset{}} = Locations.create_country(@invalid_attrs)
    # end

    # test "update_country/2 with valid data updates the country" do
    #   country = country_fixture()

    #   update_attrs = %{
    #     neighbours: "some updated neighbours",
    #     iso: "some updated iso",
    #     iso_3: "some updated iso_3",
    #     iso_numeric: 43,
    #     fips: "some updated fips",
    #     country_name: "some updated country_name",
    #     capital: "some updated capital",
    #     area: 43,
    #     population: 43,
    #     continent_code: "some updated continent",
    #     tld: "some updated tld",
    #     currency_code: "some updated currency_code",
    #     currency_name: "some updated currency_name",
    #     phone: "some updated phone",
    #     postal_code_format: "some updated postal_code_format",
    #     postal_code_regex: "some updated postal_code_regex",
    #     languages: "some updated languages",
    #     geoname_id: 246,
    #     equivalent_fips_code: "some updated equivalent_fips_code"
    #   }

    #   assert {:ok, %Country{} = country} = Locations.update_country(country, update_attrs)
    #   assert country.neighbours == "some updated neighbours"
    #   assert country.iso == "some updated iso"
    #   assert country.iso_3 == "some updated iso_3"
    #   assert country.iso_numeric == 43
    #   assert country.fips == "some updated fips"
    #   assert country.country_name == "some updated country_name"
    #   assert country.capital == "some updated capital"
    #   assert country.area == 43
    #   assert country.population == 43
    #   assert country.continent_code == "some updated continent"
    #   assert country.tld == "some updated tld"
    #   assert country.currency_code == "some updated currency_code"
    #   assert country.currency_name == "some updated currency_name"
    #   assert country.phone == "some updated phone"
    #   assert country.postal_code_format == "some updated postal_code_format"
    #   assert country.postal_code_regex == "some updated postal_code_regex"
    #   assert country.languages == "some updated languages"
    #   assert country.geoname_id == 246
    #   assert country.equivalent_fips_code == "some updated equivalent_fips_code"
    # end

    # test "update_country/2 with invalid data returns error changeset" do
    #   country = country_fixture()
    #   assert {:error, %Ecto.Changeset{}} = Locations.update_country(country, @invalid_attrs)
    #   assert country == Locations.get_country!(country.iso)
    # end

    # test "delete_country/1 deletes the country" do
    #   country = country_fixture()
    #   assert {:ok, %Country{}} = Locations.delete_country(country)
    #   assert_raise Ecto.NoResultsError, fn -> Locations.get_country!(country.iso) end
    # end

    # test "change_country/1 returns a country changeset" do
    #   country = country_fixture()
    #   assert %Ecto.Changeset{} = Locations.change_country(country)
    # end
  end

  describe "locations_administrative_division1" do
    alias Klepsidra.Locations.AdministrativeDivision1

    import Klepsidra.LocationsFixtures

    @invalid_attrs %{
      country_code: nil,
      administrative_division_code: nil,
      administrative_division_name: nil,
      administrative_division_name_ascii: nil,
      geonames_id: nil
    }

    test "list_locations_administrative_division1/0 returns all locations_administrative_division1" do
      administrative_division1 = administrative_division1_fixture()
      assert Locations.list_locations_administrative_division1() == [administrative_division1]
    end

    test "get_administrative_division1!/1 returns the administrative_division1 with given id" do
      administrative_division1 = administrative_division1_fixture()

      assert Locations.get_administrative_division1!(
               administrative_division1.country_code,
               administrative_division1.administrative_division_code
             ) == administrative_division1
    end

    test "create_administrative_division1/1 with valid data creates a administrative_division1" do
      valid_attrs = %{
        country_code: "UK",
        administrative_division_code: "SCT",
        administrative_division_name: "some administrative_division_name",
        administrative_division_name_ascii: "some administrative_division_name_ascii",
        geoname_id: 42
      }

      assert {:ok, %AdministrativeDivision1{} = administrative_division1} =
               Locations.create_administrative_division1(valid_attrs)

      assert administrative_division1.country_code == "UK"
      assert administrative_division1.administrative_division_code == "SCT"

      assert administrative_division1.administrative_division_name ==
               "some administrative_division_name"

      assert administrative_division1.administrative_division_name_ascii ==
               "some administrative_division_name_ascii"

      assert administrative_division1.geoname_id == 42
    end

    test "create_administrative_division1/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Locations.create_administrative_division1(@invalid_attrs)
    end

    test "update_administrative_division1/2 with valid data updates the administrative_division1" do
      administrative_division1 = administrative_division1_fixture()

      update_attrs = %{
        country_code: "US",
        administrative_division_code: "FL",
        administrative_division_name: "some updated administrative_division_name",
        administrative_division_name_ascii: "some updated administrative_division_name_ascii",
        geoname_id: 43
      }

      assert {:ok, %AdministrativeDivision1{} = administrative_division1} =
               Locations.update_administrative_division1(administrative_division1, update_attrs)

      assert administrative_division1.country_code == "US"
      assert administrative_division1.administrative_division_code == "FL"

      assert administrative_division1.administrative_division_name ==
               "some updated administrative_division_name"

      assert administrative_division1.administrative_division_name_ascii ==
               "some updated administrative_division_name_ascii"

      assert administrative_division1.geoname_id == 43
    end

    test "update_administrative_division1/2 with invalid data returns error changeset" do
      administrative_division1 = administrative_division1_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Locations.update_administrative_division1(administrative_division1, @invalid_attrs)

      assert administrative_division1 ==
               Locations.get_administrative_division1!(
                 administrative_division1.country_code,
                 administrative_division1.administrative_division_code
               )
    end

    test "delete_administrative_division1/1 deletes the administrative_division1" do
      administrative_division1 = administrative_division1_fixture()

      assert {:ok, %AdministrativeDivision1{}} =
               Locations.delete_administrative_division1(administrative_division1)

      assert Locations.get_administrative_division1!(
               administrative_division1.country_code,
               administrative_division1.administrative_division_code
             ) == nil
    end

    test "change_administrative_division1/1 returns a administrative_division1 changeset" do
      administrative_division1 = administrative_division1_fixture()

      assert %Ecto.Changeset{} =
               Locations.change_administrative_division1(administrative_division1)
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
