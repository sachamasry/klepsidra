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
  def get_feature_code!(feature_class, feature_code) do
    FeatureCode
    |> where([fc], fc.feature_class == ^feature_class)
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
  Gets a single country.

  Raises `Ecto.NoResultsError` if the Country does not exist.

  ## Examples

      iex> get_country!(123)
      %Country{}

      iex> get_country!(456)
      ** (Ecto.NoResultsError)

  """
  def get_country!(id), do: Repo.get!(Country, id)

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
  @spec list_cities_by_name(name_filter :: String.t()) :: [map(), ...]
  def list_cities_by_name(""), do: []

  def list_cities_by_name(name_filter) when is_bitstring(name_filter) do
    like_name = "%#{name_filter}%"

    query =
      from(
        c in City,
        left_join: fc in FeatureCode,
        on: c.feature_class == fc.feature_class,
        on: c.feature_code == fc.feature_code,
        left_join: co in Country,
        on: c.country_code == co.iso,
        where: like(c.name, ^like_name),
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
          population: c.population,
          country_name: co.country_name,
          feature_description: fc.description
        }
      )

    Repo.all(query)
  end

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
