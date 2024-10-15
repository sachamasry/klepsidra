defmodule Klepsidra.Locations do
  @moduledoc """
  Location utilities for countries, subdivisions and cities.

  The module is largely a wrapper for Plausible Analytics'
  [`Location` package](https://github.com/plausible/location/tree/main).
  """

  import Ecto.Query, warn: false
  alias Klepsidra.Repo

  alias Klepsidra.Locations.FeatureClass
  alias Klepsidra.Locations.City

  @doc """
  Returns the list of feature_classes.

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
  def get_feature_class!(feature_class), do: Repo.get!(FeatureClass, feature_class)

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

  @ets_cities Location.City.ByLabel

  @doc false
  def search_city(search_phrase) do
    search_phrase = String.downcase(search_phrase)

    :ets.foldl(
      fn
        {{name, country_code}, _id}, acc ->
          if String.contains?(String.downcase(name), search_phrase) do
            country = Location.get_country(country_code)
            [{name, country_code, country.name, country.flag} | acc]
          else
            acc
          end
      end,
      [],
      @ets_cities
      # Location.City.ByLabel
    )
    |> Enum.sort_by(fn {city, _country_code, country_name, _flag} ->
      {!String.starts_with?(city, search_phrase), byte_size(city), country_name}
    end)
    |> Enum.map(fn {city, _country_code, country_name, flag} ->
      "#{city} - #{country_name}  #{flag}"
    end)
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
        where: like(c.name, ^like_name),
        order_by: [desc: c.population, asc: c.name],
        select: %{
          id: c.id,
          name: c.name,
          country_code: c.country_code,
          feature_code: c.feature_code,
          population: c.population
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
