defmodule Klepsidra.Utilities do
  @moduledoc """
  The Utilities context.
  """

  import Ecto.Query, warn: false
  alias Klepsidra.Repo

  alias Klepsidra.Utilities.City

  @doc """
  Returns the list of cities.

  ## Examples

      iex> Utilities.list_cities()
      [%Utilities.City{}, ...]

  """
  def list_cities do
    Repo.all(City)
  end

  @doc """
  Returns a list of cities containing the name fragment, sorted by
  descending population size, and by name in alphabetical order.

  ## Examples

      iex> Utilities.list_cities_by_name("")
      []

      iex> Utilities.list_cities_by_name("london")
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

      iex> Utilities.get_city!(123)
      %Utilities.City{}

      iex> Utilities.get_city!(456)
      ** (Ecto.NoResultsError)

  """
  def get_city!(id), do: Repo.get!(City, id)

  @doc """
  Creates a city.

  ## Examples

      iex> Utilities.create_city(%{name: "Londinium"})
      {:ok, %Utilities.City{}}

      iex> Utilities.create_city(%{name: 123_456})
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

      iex> Utilities.update_city(city, %{name: "Troy"})
      {:ok, %Utilities.City{}}

      iex> Utilities.update_city(city, %{field: 300})
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

      iex> Utilities.delete_city(city)
      {:ok, %Utilities.City{}}

      iex> Utilities.delete_city(city)
      {:error, %Ecto.Changeset{}}

  """
  def delete_city(%City{} = city) do
    Repo.delete(city)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking city changes.

  ## Examples

      iex> Utilities.change_city(city)
      %Ecto.Changeset{data: %Utilities.City{}}

  """
  def change_city(%City{} = city, attrs \\ %{}) do
    City.changeset(city, attrs)
  end
end
