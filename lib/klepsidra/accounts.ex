defmodule Klepsidra.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Klepsidra.Repo

  alias Klepsidra.Accounts.User

  @doc """
  Query combinator for limiting returned records.
  """
  @spec limit_returned_results(query :: Ecto.Query.t(), limit :: integer()) :: Ecto.Query.t()
  def limit_returned_results(query, limit) do
    from zz in query,
      limit: ^limit
  end

  @spec from_users() :: Ecto.Query.t()
  def from_users() do
    from(u in User, as: :users)
  end

  @spec filter_users_matching_name(query :: Ecto.Query.t(), name_filter :: String.t()) ::
          Ecto.Query.t()
  def filter_users_matching_name(query, name_filter) do
    like_name = "%#{name_filter}%"

    from [users: u] in query,
      where: like(u.user_name, ^like_name)
  end

  @spec filter_users_by_id(query :: Ecto.Query.t(), id :: Ecto.UUID.t()) ::
          Ecto.Query.t()
  def filter_users_by_id(query, id) do
    from [users: u] in query,
      where: u.id == ^id
  end

  @spec order_by_users_name_asc(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def order_by_users_name_asc(query) do
    from [users: u] in query,
      order_by: [asc: u.user_name]
  end

  @spec select_user_name(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def select_user_name(query) do
    from [users: u] in query,
      select: %{
        id: u.id,
        user_name: u.user_name,
        login_email: u.login_email,
        description: u.description
      }
  end

  @spec select_users_options_for_select_name(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def select_users_options_for_select_name(query) do
    from [users: u] in query,
      select: %{value: u.id, label: u.user_name}
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    User |> order_by(asc: :user_name) |> Repo.all()
  end

  @doc """
  Returns a list of user names.

  ## Examples

      iex> list_user_names()
      [%{}, ...]

  """
  @spec list_user_names() :: [%{value: Ecto.UUID.t(), label: String.t()}, ...]
  def list_user_names() do
    from_users()
    |> select_user_name()
    |> Repo.all()
  end

  @spec list_users_options_for_select_matching_name(
          name_filter :: String.t(),
          options :: keyword()
        ) ::
          [%{value: Ecto.UUID.t(), label: String.t()}, ...]

  def list_users_options_for_select_matching_name(name_filter, options \\ [])

  def list_users_options_for_select_matching_name(name_filter, options)
      when is_bitstring(name_filter) do
    max_result_count = Keyword.get(options, :limit, 25)

    from_users()
    |> filter_users_matching_name(name_filter)
    |> limit_returned_results(max_result_count)
    |> select_users_options_for_select_name()
    |> Repo.all()
  end

  def list_users_options_for_select_matching_name(_, _), do: [%{value: "", label: ""}]

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Constructs an HTML `select` option for a single user entity,
  for use by the `live_select` live component.

  Given a current `user_id`, a reference to the user primary key
  in the `users` table, calls the relevant query, obtaining necessary
  fields to construct a full, unambiguous, user name.

  ## Returns

  Returns a single map:
  ```
  %{
    label: << user_name >>,
    value: << user_id (UUID) >>
  ```

  ## Examples

      iex> get_user_option_for_select("abc")
      %{label: "...", value: "..."}

      iex> get_user_option_for_select(123)
      %{label: "", value: ""}
  """
  @spec get_user_option_for_select(id :: Ecto.UUID.t()) :: %{
          label: String.t(),
          value: String.t()
        }
  def get_user_option_for_select(""), do: %{label: "", value: ""}

  def get_user_option_for_select(id) when is_bitstring(id) do
    from_users()
    |> filter_users_by_id(id)
    |> select_users_options_for_select_name()
    |> Repo.one()
  end

  def get_user_option_for_select(_id), do: %{label: "", value: ""}

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
