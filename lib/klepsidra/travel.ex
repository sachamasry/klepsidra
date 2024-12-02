defmodule Klepsidra.Travel do
  @moduledoc """
  The Travel context.
  """

  import Ecto.Query, warn: false
  alias Klepsidra.Repo

  alias Klepsidra.Accounts.User
  alias Klepsidra.Documents.UserDocument
  alias Klepsidra.Locations.Country
  alias Klepsidra.Travel.Trip

  @doc """
  Query combinator for limiting returned records.
  """
  @spec limit_returned_results(query :: Ecto.Query.t(), limit :: integer()) :: Ecto.Query.t()
  def limit_returned_results(query, limit) do
    from zz in query,
      limit: ^limit
  end

  @spec from_trips() :: Ecto.Query.t()
  def from_trips() do
    from(t in Trip, as: :trips)
  end

  @spec filter_trips_by_id(query :: Ecto.Query.t(), id :: Ecto.UUID.t()) ::
          Ecto.Query.t()
  def filter_trips_by_id(query, id) do
    from [trips: t] in query,
      where: t.id == ^id
  end

  @spec order_by_trips_entry_asc_exit_asc(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def order_by_trips_entry_asc_exit_asc(query) do
    from [trips: t] in query,
      order_by: [asc: t.entry_date, asc: t.exit_date]
  end

  @spec join_trips_users(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def join_trips_users(query) do
    from [trips: t] in query,
      left_join: u in User,
      as: :user,
      on: t.user_id == u.id
  end

  @spec join_trips_user_documents(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def join_trips_user_documents(query) do
    from [trips: t] in query,
      left_join: ud in UserDocument,
      as: :user_document,
      on: t.user_document_id == ud.id
  end

  @spec join_trips_countries(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def join_trips_countries(query) do
    from [trips: t] in query,
      left_join: co in Country,
      as: :country,
      on: t.country_id == co.iso_3_country_code
  end

  @spec select_trips_user_and_country(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def select_trips_user_and_country(query) do
    from [trips: t, user: u, country: co] in query,
      select: %{
        id: t.id,
        user_id: t.user_id,
        user_name: u.user_name,
        country_id: t.country_id,
        country_name: co.country_name,
        description: t.description |> coalesce(""),
        entry_date: t.entry_date,
        entry_point: t.entry_point,
        exit_date: t.exit_date,
        exit_point: t.exit_point
      }
  end

  @spec select_trips_user_document_and_country(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def select_trips_user_document_and_country(query) do
    from [trips: t, user: u, user_document: ud, country: co] in query,
      select: %{
        id: t.id,
        user_id: t.user_id,
        user_name: u.user_name,
        user_document_id: t.user_document_id,
        user_document_name:
          fragment(
            "concat(?, ' (Ref: ', ?, ', Validity: ', ?, '-', ?, ')')",
            ud.name,
            ud.unique_reference_number,
            ud.issued_at,
            ud.expires_at
          ),
        country_id: t.country_id,
        country_name: co.country_name,
        description: t.description |> coalesce(""),
        entry_date: t.entry_date,
        entry_point: t.entry_point,
        exit_date: t.exit_date,
        exit_point: t.exit_point
      }
  end

  @doc """
  Returns the list of trips.

  ## Examples

      iex> list_trips()
      [%Trip{}, ...]

  """
  def list_trips do
    Repo.all(Trip)
  end

  @doc """
  Returns a list of trips with the user and country names.

  ## Examples

      iex> list_trips_with_user_and_country()
      [%{}, ...]

  """
  @spec list_trips_with_user_and_country() :: [map(), ...]
  def list_trips_with_user_and_country do
    from_trips()
    |> join_trips_users()
    |> join_trips_countries()
    |> order_by_trips_entry_asc_exit_asc()
    |> select_trips_user_and_country()
    |> Repo.all()
  end

  @doc """
  Gets a single trip.

  Raises `Ecto.NoResultsError` if the Trip does not exist.

  ## Examples

      iex> get_trip!(123)
      %Trip{}

      iex> get_trip!(456)
      ** (Ecto.NoResultsError)

  """
  def get_trip!(id), do: Repo.get!(Trip, id)

  @doc """
  Returns a single trip, with user and country names.

  ## Examples

      iex> get_trip_with_user_and_country(id)
      %{}

  """
  @spec get_trip_with_user_and_country(id :: Ecto.UUID.t()) :: [
          map(),
          ...
        ]
  def get_trip_with_user_and_country(id) when is_bitstring(id) do
    from_trips()
    |> join_trips_users()
    |> join_trips_countries()
    |> filter_trips_by_id(id)
    |> select_trips_user_and_country()
    |> Repo.one()
  end

  @doc """
  Returns a single trip, with user, document used and country names.

  ## Examples

      iex> get_trip_with_user_document_and_country(id)
      %{}

  """
  @spec get_trip_with_user_document_and_country(id :: Ecto.UUID.t()) :: [
          map(),
          ...
        ]
  def get_trip_with_user_document_and_country(id) when is_bitstring(id) do
    from_trips()
    |> join_trips_users()
    |> join_trips_user_documents()
    |> join_trips_countries()
    |> filter_trips_by_id(id)
    |> select_trips_user_document_and_country()
    |> Repo.one()
  end

  @doc """
  Creates a trip.

  ## Examples

      iex> create_trip(%{field: value})
      {:ok, %Trip{}}

      iex> create_trip(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_trip(attrs \\ %{}) do
    %Trip{}
    |> Trip.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a trip.

  ## Examples

      iex> update_trip(trip, %{field: new_value})
      {:ok, %Trip{}}

      iex> update_trip(trip, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_trip(%Trip{} = trip, attrs) do
    trip
    |> Trip.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a trip.

  ## Examples

      iex> delete_trip(trip)
      {:ok, %Trip{}}

      iex> delete_trip(trip)
      {:error, %Ecto.Changeset{}}

  """
  def delete_trip(%Trip{} = trip) do
    Repo.delete(trip)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking trip changes.

  ## Examples

      iex> change_trip(trip)
      %Ecto.Changeset{data: %Trip{}}

  """
  def change_trip(%Trip{} = trip, attrs \\ %{}) do
    Trip.changeset(trip, attrs)
  end
end
