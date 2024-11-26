defmodule Klepsidra.Locations do
  @moduledoc """
  Location utilities for countries, subdivisions and cities.

  The module is largely a wrapper for Plausible Analytics'
  [`Location` package](https://github.com/plausible/location/tree/main).
  """

  import Ecto.Query, warn: false
  alias Klepsidra.Repo

  alias Klepsidra.Locations.FeatureClass
  alias Klepsidra.Locations.FeatureCode
  alias Klepsidra.Locations.Continent
  alias Klepsidra.Locations.Country
  alias Klepsidra.Locations.AdministrativeDivisions1
  alias Klepsidra.Locations.AdministrativeDivisions2
  alias Klepsidra.Locations.City

  @doc """
  Returns the list of locations_feature_classes.

  ## Examples

      iex> list_feature_classes()
      [%FeatureClass{}, ...]

  """
  def list_feature_classes do
    Repo.all(FeatureClass)
  end

  @doc """
  Gets a single feature_class.

  Raises `Ecto.NoResultsError` if the Feature class does not exist.

  ## Examples

      iex> get_feature_class!(123)
      %FeatureClass{}

      iex> get_feature_class!(456)
      ** (Ecto.NoResultsError)

  """
  def get_feature_class!(feature_class) do
    FeatureClass |> where([fc], fc.feature_class == ^feature_class) |> Repo.one()
  end

  @doc """
  Creates a feature_class.

  ## Examples

      iex> create_feature_class(%{field: value})
      {:ok, %FeatureClass{}}

      iex> create_feature_class(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_feature_class(attrs \\ %{}) do
    %FeatureClass{}
    |> FeatureClass.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a feature_class.

  ## Examples

      iex> update_feature_class(feature_class, %{field: new_value})
      {:ok, %FeatureClass{}}

      iex> update_feature_class(feature_class, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_feature_class(%FeatureClass{} = feature_class, attrs) do
    feature_class
    |> FeatureClass.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a feature_class.

  ## Examples

      iex> delete_feature_class(feature_class)
      {:ok, %FeatureClass{}}

      iex> delete_feature_class(feature_class)
      {:error, %Ecto.Changeset{}}

  """
  def delete_feature_class(%FeatureClass{} = feature_class) do
    Repo.delete(feature_class)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking feature_class changes.

  ## Examples

      iex> change_feature_class(feature_class)
      %Ecto.Changeset{data: %FeatureClass{}}

  """
  def change_feature_class(%FeatureClass{} = feature_class, attrs \\ %{}) do
    FeatureClass.changeset(feature_class, attrs)
  end

  @doc """
  Returns the list of feature_codes.

  ## Examples

      iex> list_feature_codes()
      [%FeatureCode{}, ...]

  """
  def list_feature_codes do
    Repo.all(FeatureCode)
  end

  @doc """
  Gets a single feature_code.

  Raises `Ecto.NoResultsError` if the Feature code does not exist.

  ## Examples

      iex> get_feature_code!("P", "PPL")
      %FeatureCode{}

      iex> get_feature_code!("X", "YYY")
      ** (Ecto.NoResultsError)

  """
  def get_feature_code!(feature_code) do
    FeatureCode
    |> where([fc], fc.feature_code == ^feature_code)
    |> Repo.one()
  end

  @doc """
  Creates a feature_code.

  ## Examples

      iex> create_feature_code(%{field: value})
      {:ok, %FeatureCode{}}

      iex> create_feature_code(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_feature_code(attrs \\ %{}) do
    %FeatureCode{}
    |> FeatureCode.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a feature_code.

  ## Examples

      iex> update_feature_code(feature_code, %{field: new_value})
      {:ok, %FeatureCode{}}

      iex> update_feature_code(feature_code, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_feature_code(%FeatureCode{} = feature_code, attrs) do
    feature_code
    |> FeatureCode.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a feature_code.

  ## Examples

      iex> delete_feature_code(feature_code)
      {:ok, %FeatureCode{}}

      iex> delete_feature_code(feature_code)
      {:error, %Ecto.Changeset{}}

  """
  def delete_feature_code(%FeatureCode{} = feature_code) do
    Repo.delete(feature_code)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking feature_code changes.

  ## Examples

      iex> change_feature_code(feature_code)
      %Ecto.Changeset{data: %FeatureCode{}}

  """
  def change_feature_code(%FeatureCode{} = feature_code, attrs \\ %{}) do
    FeatureCode.changeset(feature_code, attrs)
  end

  @doc """
  Returns the list of locations_continents.

  ## Examples

      iex> list_continents()
      [%Continent{}, ...]

  """
  def list_continents do
    Repo.all(Continent)
  end

  @doc """
  Gets a single continent.

  Raises `Ecto.NoResultsError` if the Continent does not exist.

  ## Examples

      iex> get_continent!(123)
      %Continent{}

      iex> get_continent!(456)
      ** (Ecto.NoResultsError)

  """
  def get_continent!(continent_code) do
    Continent |> where([c], c.continent_code == ^continent_code) |> Repo.one()
  end

  @doc """
  Creates a continent.

  ## Examples

      iex> create_continent(%{field: value})
      {:ok, %Continent{}}

      iex> create_continent(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_continent(attrs \\ %{}) do
    %Continent{}
    |> Continent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a continent.

  ## Examples

      iex> update_continent(continent, %{field: new_value})
      {:ok, %Continent{}}

      iex> update_continent(continent, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_continent(%Continent{} = continent, attrs) do
    continent
    |> Continent.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a continent.

  ## Examples

      iex> delete_continent(continent)
      {:ok, %Continent{}}

      iex> delete_continent(continent)
      {:error, %Ecto.Changeset{}}

  """
  def delete_continent(%Continent{} = continent) do
    Repo.delete(continent)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking continent changes.

  ## Examples

      iex> change_continent(continent)
      %Ecto.Changeset{data: %Continent{}}

  """
  def change_continent(%Continent{} = continent, attrs \\ %{}) do
    Continent.changeset(continent, attrs)
  end

  @doc """
  Returns the list of countries.

  ## Examples

      iex> list_countries()
      [%Country{}, ...]

  """
  def list_countries do
    Repo.all(Country)
  end

  @doc """
  Returns a list of countries containing the name fragment, sorted by
  descending population size, and by name in alphabetical order.

  ## Examples

      iex> Locations.list_countries_by_name("")
      []

      iex> Locations.list_countries_by_name("Canada")
      [%{}, ...]
  """
  @spec list_countries_by_name(name_filter :: String.t(), options :: keyword()) :: [map(), ...]
  def list_countries_by_name(name_filter, options \\ [])

  def list_countries_by_name("", _), do: []

  def list_countries_by_name(name_filter, _options) when is_bitstring(name_filter) do
    # Keyword.get(options, :limit, 25)
    max_result_count = 25
    like_name = "%#{name_filter}%"

    query =
      from(
        co in Country,
        where: like(co.country_name, ^like_name),
        order_by: [
          desc: co.population,
          desc: co.area,
          asc: co.country_name
        ],
        select: %{
          iso_2_country_code: co.iso_country_code,
          iso_3_country_code: co.iso_3_country_code,
          country_name: co.country_name
        },
        limit: ^max_result_count
      )

    Repo.all(query)
  end

  def list_countries_by_name(_, _), do: []

  @doc """
  Searches for countries, forming the result into an HTML usable
  %{value: id, label: city} map.
  """
  @spec country_search(country_name :: String.t()) :: [map()]
  def country_search(country_name) when is_bitstring(country_name) do
    country_name
    |> list_countries_by_name(limit: 25)
    |> Enum.map(fn country ->
      %{value: country.iso_3_country_code, label: "#{country.country_name}"}
    end)
  end

  def country_search(_name), do: []

  @doc """
  Gets a single country.

  Raises `Ecto.NoResultsError` if the Country does not exist.

  ## Examples

      iex> get_country!(123)
      %Country{}

      iex> get_country!(456)
      ** (Ecto.NoResultsError)

  """
  def get_country!(iso_country_code) do
    Country
    |> where([c], c.iso_country_code == ^iso_country_code)
    |> Repo.one()
  end

  @doc """
  Gets a single country, with ISO three-letter code 
  and country name.

  Returns `nil` if the country does not exist.

  ## Examples

      iex> Locations.get_country_by_iso_3_code!(123)
      %Locations.Country{}

      iex> Locations.get_country_by_iso_3_code!(456)
      nil

  """
  @spec get_country_by_iso_3_code!(country_code :: String.t()) :: Country.t() | nil
  def get_country_by_iso_3_code!(""), do: nil

  def get_country_by_iso_3_code!(country_code) when is_bitstring(country_code) do
    query =
      from(
        co in Country,
        where: co.iso_3_country_code == ^country_code,
        select: %{value: co.iso_3_country_code, label: co.country_name}
      )

    Repo.one(query)
  end

  def get_country_by_iso_3_code!(_), do: nil

  @doc """
  Creates a country.

  ## Examples

      iex> create_country(%{field: value})
      {:ok, %Country{}}

      iex> create_country(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_country(attrs \\ %{}) do
    %Country{}
    |> Country.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a country.

  ## Examples

      iex> update_country(country, %{field: new_value})
      {:ok, %Country{}}

      iex> update_country(country, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_country(%Country{} = country, attrs) do
    country
    |> Country.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a country.

  ## Examples

      iex> delete_country(country)
      {:ok, %Country{}}

      iex> delete_country(country)
      {:error, %Ecto.Changeset{}}

  """
  def delete_country(%Country{} = country) do
    Repo.delete(country)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking country changes.

  ## Examples

      iex> change_country(country)
      %Ecto.Changeset{data: %Country{}}

  """
  def change_country(%Country{} = country, attrs \\ %{}) do
    Country.changeset(country, attrs)
  end

  @doc """
  Returns the list of level 1 administrative divisions.

  ## Examples

      iex> list_administrative_divisions_1()
      [%AdministrativeDivisions1{}, ...]

  """
  def list_administrative_divisions_1 do
    Repo.all(AdministrativeDivisions1)
  end

  @doc """
  Gets a single level 1 administrative division.

  Raises `Ecto.NoResultsError` if the `administrative_division_1` does not exist.

  ## Examples

      iex> get_administrative_division_1!(123)
      %AdministrativeDivisions1{}

      iex> get_administrative_division_1!(456)
      ** (Ecto.NoResultsError)

  """
  def get_administrative_division_1!(administrative_division_1_code) do
    AdministrativeDivisions1
    |> where([ad1], ad1.administrative_division_1_code == ^administrative_division_1_code)
    |> Repo.one()
  end

  @doc """
  Creates a new level 1 administrative division.

  ## Examples

      iex> create_administrative_division_1(%{field: value})
      {:ok, %AdministrativeDivisions1{}}

      iex> create_administrative_division_1(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_administrative_division_1(attrs \\ %{}) do
    %AdministrativeDivisions1{}
    |> AdministrativeDivisions1.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a level 1 administrative division.

  ## Examples

      iex> update_administrative_division_1(administrative_division_1, %{field: new_value})
      {:ok, %AdministrativeDivisions1{}}

      iex> update_administrative_division_1(administrative_division_1, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_administrative_division_1(
        %AdministrativeDivisions1{} = administrative_division_1,
        attrs
      ) do
    administrative_division_1
    |> AdministrativeDivisions1.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a level 1 administrative division.

  ## Examples

      iex> delete_administrative_division_1(administrative_division_1)
      {:ok, %AdministrativeDivisions1{}}

      iex> delete_administrative_division_1(administrative_division_1)
      {:error, %Ecto.Changeset{}}

  """
  def delete_administrative_division_1(%AdministrativeDivisions1{} = administrative_division_1) do
    Repo.delete(administrative_division_1)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking `administrative_divisions_1` changes.

  ## Examples

      iex> change_administrative_division_1(administrative_division_1)
      %Ecto.Changeset{data: %AdministrativeDivisions1{}}

  """
  def change_administrative_division_1(
        %AdministrativeDivisions1{} = administrative_division_1,
        attrs \\ %{}
      ) do
    AdministrativeDivisions1.changeset(administrative_division_1, attrs)
  end

  @doc """
  Returns the list of level 2 administrative divisions.

  ## Examples

      iex> list_locations_administrative_divisions_2()
      [%AdministrativeDivisions2{}, ...]

  """
  def list_locations_administrative_divisions_2 do
    Repo.all(AdministrativeDivisions2)
  end

  @doc """
  Gets a single level 2 administrative division.

  Raises `Ecto.NoResultsError` if the `administrative_division_2` does not exist.

  ## Examples

      iex> get_administrative_division_2!(123)
      %AdministrativeDivisions2{}

      iex> get_administrative_division_2!(456)
      ** (Ecto.NoResultsError)

  """
  def get_administrative_division_2!(administrative_division_2_code) do
    AdministrativeDivisions2
    |> where([ad2], ad2.administrative_division_2_code == ^administrative_division_2_code)
    |> Repo.one()
  end

  @doc """
  Creates a level 2 administrative division.

  ## Examples

      iex> create_administrative_division_2(%{field: value})
      {:ok, %AdministrativeDivisions2{}}

      iex> create_administrative_division_2(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_administrative_division_2(attrs \\ %{}) do
    %AdministrativeDivisions2{}
    |> AdministrativeDivisions2.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a level 2 administrative division.

  ## Examples

      iex> update_administrative_division_2(administrative_division_2, %{field: new_value})
      {:ok, %AdministrativeDivisions2{}}

      iex> update_administrative_division_2(administrative_division_2, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_administrative_division_2(
        %AdministrativeDivisions2{} = administrative_division_2,
        attrs
      ) do
    administrative_division_2
    |> AdministrativeDivisions2.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a level 2 administrative division.

  ## Examples

      iex> delete_administrative_division_2(administrative_division_2)
      {:ok, %AdministrativeDivisions2{}}

      iex> delete_administrative_division_2(administrative_division_2)
      {:error, %Ecto.Changeset{}}

  """
  def delete_administrative_division_2(%AdministrativeDivisions2{} = administrative_division_2) do
    Repo.delete(administrative_division_2)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking `administrative_division_2` changes.

  ## Examples

      iex> change_administrative_division_2(administrative_division_2)
      %Ecto.Changeset{data: %AdministrativeDivision2{}}

  """
  def change_administrative_division_2(
        %AdministrativeDivisions2{} = administrative_division_2,
        attrs \\ %{}
      ) do
    AdministrativeDivisions2.changeset(administrative_division_2, attrs)
  end

  @doc """
  Returns the list of cities.

  ## Examples

      iex> Locations.list_cities()
      [%Locations.City{}, ...]

  """
  def list_cities do
    Repo.all(City)
  end

  @doc """
  Returns a list of cities containing the name fragment, sorted by
  descending population size, and by name in alphabetical order.

  ## Examples

      iex> Locations.list_cities_by_name("")
      []

      iex> Locations.list_cities_by_name("london")
      [%{}, ...]
  """
  @spec list_cities_by_name(name_filter :: String.t(), options :: keyword()) :: [map(), ...]
  def list_cities_by_name(name_filter, options \\ [])

  def list_cities_by_name("", _), do: []

  def list_cities_by_name(name_filter, _options) when is_bitstring(name_filter) do
    # Keyword.get(options, :limit, 25)
    max_result_count = 25
    like_name = "%#{name_filter}%"

    query =
      from(
        c in City,
        left_join: fc in FeatureCode,
        on: c.feature_code == fc.feature_code,
        left_join: co in Country,
        on: c.country_code == co.iso_country_code,
        where: like(c.ascii_name, ^like_name),
        left_join: ad in AdministrativeDivisions1,
        on: c.administrative_division_1_code == ad.administrative_division_1_code,
        order_by: [
          asc: fc.order,
          desc: c.population,
          desc: co.population,
          desc: co.area,
          asc: c.name
        ],
        select: %{
          id: c.id,
          name: c.name,
          level_1_division: ad.administrative_division_1_name |> coalesce(""),
          country_name: co.country_name,
          feature_description: fc.description
        },
        limit: ^max_result_count
      )

    Repo.all(query)
  end

  def list_cities_by_name(_, _), do: []

  @doc """
  Searches for cities, forming the result into an HTML usable
  %{value: id, label: city} map.
  """
  @spec city_search(city_name :: String.t()) :: [map()]
  def city_search(city_name) when is_bitstring(city_name) do
    city_name
    |> list_cities_by_name(limit: 25)
    |> Enum.map(fn city ->
      %{value: city.id, label: "#{city.name}, #{city.level_1_division} - #{city.country_name}"}
    end)
  end

  def city_search(_name), do: []

  @doc """
  Gets a single city.

  Raises `Ecto.NoResultsError` if the City does not exist.

  ## Examples

      iex> Locations.get_city!(123)
      %Locations.City{}

      iex> Locations.get_city!(456)
      ** (Ecto.NoResultsError)

  """
  def get_city!(id), do: Repo.get!(City, id)

  @doc """
  Gets a single city, with level 1 administrative division or territory,
  and country name.

  Returns `nil` if the City does not exist.

  ## Examples

      iex> Locations.get_city_territory_and_country!(123)
      %Locations.City{}

      iex> Locations.get_city_territory_and_country!(456)
      nil

  """
  @spec get_city_territory_and_country!(city_id :: Ecto.UUID.t()) :: City.t() | nil
  def get_city_territory_and_country!(""), do: nil

  def get_city_territory_and_country!(city_id) when is_bitstring(city_id) do
    query =
      from(
        c in City,
        left_join: fc in FeatureCode,
        on: c.feature_code == fc.feature_code,
        left_join: co in Country,
        on: c.country_code == co.iso_country_code,
        left_join: ad in AdministrativeDivisions1,
        on: c.administrative_division_1_code == ad.administrative_division_1_code,
        where: c.id == ^city_id,
        select: %{
          id: c.id,
          name: c.name,
          level_1_division: ad.administrative_division_1_name |> coalesce(""),
          country_name: co.country_name,
          feature_description: fc.description
        }
      )

    Repo.one(query)
  end

  def get_city_territory_and_country!(_), do: nil

  @doc """
  Creates a city.

  ## Examples

      iex> Locations.create_city(%{name: "Londinium"})
      {:ok, %Locations.City{}}

      iex> Locations.create_city(%{name: 123_456})
      {:error, %Ecto.Changeset{}}

  """
  def create_city(attrs \\ %{}) do
    %City{}
    |> City.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a city.

  ## Examples

      iex> Locations.update_city(city, %{name: "Troy"})
      {:ok, %Locations.City{}}

      iex> Locations.update_city(city, %{field: 300})
      {:error, %Ecto.Changeset{}}

  """
  def update_city(%City{} = city, attrs) do
    city
    |> City.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a city.

  ## Examples

      iex> Locations.delete_city(city)
      {:ok, %Locations.City{}}

      iex> Locations.delete_city(city)
      {:error, %Ecto.Changeset{}}

  """
  def delete_city(%City{} = city) do
    Repo.delete(city)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking city changes.

  ## Examples

      iex> Locations.change_city(city)
      %Ecto.Changeset{data: %Locations.City{}}

  """
  def change_city(%City{} = city, attrs \\ %{}) do
    City.changeset(city, attrs)
  end
end
