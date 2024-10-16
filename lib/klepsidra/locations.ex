defmodule Klepsidra.Locations do
  @moduledoc """
  Location utilities for countries, subdivisions and cities.

  The module is largely a wrapper for Plausible Analytics'
  [`Location` package](https://github.com/plausible/location/tree/main).
  """

  import Ecto.Query, warn: false
  alias Klepsidra.Repo

  alias Klepsidra.Locations.FeatureCode
  alias Klepsidra.Locations.City

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
