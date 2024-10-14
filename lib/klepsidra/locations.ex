defmodule Klepsidra.Locations do
  @moduledoc """
  Location utilities for countries, subdivisions and cities.

  The module is largely a wrapper for Plausible Analytics'
  [`Location` package](https://github.com/plausible/location/tree/main).
  """

  import Ecto.Query, warn: false
  alias Klepsidra.Repo

  alias Klepsidra.Locations.FeatureClass

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
end
