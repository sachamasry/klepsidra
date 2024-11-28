defmodule Klepsidra.Documents do
  @moduledoc """
  The Documents context.
  """

  import Ecto.Query, warn: false
  alias Klepsidra.Repo

  alias Klepsidra.Documents.DocumentType
  alias Klepsidra.Locations.Country

  @doc """
  Returns the list of document_types.

  ## Examples

      iex> list_document_types()
      [%DocumentType{}, ...]

  """
  def list_document_types do
    Repo.all(DocumentType)
  end

  @doc """
  Gets a single document_type.

  Raises `Ecto.NoResultsError` if the Document type does not exist.

  ## Examples

      iex> get_document_type!(123)
      %DocumentType{}

      iex> get_document_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_document_type!(id), do: Repo.get!(DocumentType, id)

  @doc """
  Creates a document_type.

  ## Examples

      iex> create_document_type(%{field: value})
      {:ok, %DocumentType{}}

      iex> create_document_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_document_type(attrs \\ %{}) do
    %DocumentType{}
    |> DocumentType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a document_type.

  ## Examples

      iex> update_document_type(document_type, %{field: new_value})
      {:ok, %DocumentType{}}

      iex> update_document_type(document_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_document_type(%DocumentType{} = document_type, attrs) do
    document_type
    |> DocumentType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a document_type.

  ## Examples

      iex> delete_document_type(document_type)
      {:ok, %DocumentType{}}

      iex> delete_document_type(document_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_document_type(%DocumentType{} = document_type) do
    Repo.delete(document_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking document_type changes.

  ## Examples

      iex> change_document_type(document_type)
      %Ecto.Changeset{data: %DocumentType{}}

  """
  def change_document_type(%DocumentType{} = document_type, attrs \\ %{}) do
    DocumentType.changeset(document_type, attrs)
  end

  alias Klepsidra.Documents.UserDocument

  @doc """
  Returns the list of user_documents.

  ## Examples

      iex> list_user_documents()
      [%UserDocument{}, ...]

  """
  def list_user_documents do
    Repo.all(UserDocument)
  end

  @doc """
  Gets a single user_document.

  Raises `Ecto.NoResultsError` if the User document does not exist.

  ## Examples

      iex> get_user_document!(123)
      %UserDocument{}

      iex> get_user_document!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_document!(id), do: Repo.get!(UserDocument, id)

  @doc """
  Creates a user_document.

  ## Examples

      iex> create_user_document(%{field: value})
      {:ok, %UserDocument{}}

      iex> create_user_document(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_document(attrs \\ %{}) do
    %UserDocument{}
    |> UserDocument.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_document.

  ## Examples

      iex> update_user_document(user_document, %{field: new_value})
      {:ok, %UserDocument{}}

      iex> update_user_document(user_document, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_document(%UserDocument{} = user_document, attrs) do
    user_document
    |> UserDocument.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_document.

  ## Examples

      iex> delete_user_document(user_document)
      {:ok, %UserDocument{}}

      iex> delete_user_document(user_document)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_document(%UserDocument{} = user_document) do
    Repo.delete(user_document)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_document changes.

  ## Examples

      iex> change_user_document(user_document)
      %Ecto.Changeset{data: %UserDocument{}}

  """
  def change_user_document(%UserDocument{} = user_document, attrs \\ %{}) do
    UserDocument.changeset(user_document, attrs)
  end

  alias Klepsidra.Documents.DocumentIssuer

  @doc """
  Returns the list of document_issuers.

  ## Examples

      iex> list_document_issuers()
      [%DocumentIssuer{}, ...]

  """
  def simple_list_document_issuers do
    Repo.all(DocumentIssuer)
  end

  def list_document_issuers() do
    from(di in DocumentIssuer)
  end

  def filter_document_issuers_matching_name(query, name_filter) do
    like_name = "%#{name_filter}%"

    from di in query,
      where: like(di.name, ^like_name)
  end

  def filter_document_issuers_by_id(query, id) do
    from di in query,
      where: di.id == ^id
  end

  def order_by_document_issuer_name_asc(query) do
    from di in query,
      order_by: [asc: di.name]
  end

  def join_country_table(query) do
    from di in query,
      left_join: co in Country,
      on: di.country_id == co.iso_3_country_code
  end

  def limit_returned_results(query, limit) do
    from di in query,
      limit: ^limit
  end

  def select_document_issuer_name(query) do
    from di in query,
      select: %{value: di.id, label: di.name}
  end

  def select_name_and_country(query) do
    from [di, co] in query,
      select: %{
        id: di.id,
        name: di.name,
        description: di.description,
        country_id: di.country_id,
        country_name: co.country_name,
        contact_information: di.contact_information,
        website_url: di.website_url
      }
  end

  def select_document_issuer_options_for_select_name_and_country(query) do
    from [di, co] in query,
      select: %{value: di.id, label: di.name, country_name: co.country_name}
  end

  def list_document_issuers_options_for_select_matching_name_with_country(
        name_filter,
        options \\ []
      ) do
    max_result_count = Keyword.get(options, :limit, 25)

    list_document_issuers()
    |> filter_document_issuers_matching_name(name_filter)
    |> join_country_table()
    |> limit_returned_results(max_result_count)
    |> select_document_issuer_options_for_select_name_and_country()
    |> Repo.all()
  end

  @doc """
  Returns the list of document_issuers.

  ## Examples

      iex> list_document_issuers_with_country()
      [%{}, ...]

  """
  @spec list_document_issuers_with_country() :: [map(), ...]
  def list_document_issuers_with_country do
    list_document_issuers()
    |> join_country_table()
    |> select_name_and_country()
    |> Repo.all()
  end

  @doc """
  Gets a single document_issuer.

  Raises `Ecto.NoResultsError` if the Document issuer does not exist.

  ## Examples

      iex> get_document_issuer!(123)
      %DocumentIssuer{}

      iex> get_document_issuer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_document_issuer!(id), do: Repo.get!(DocumentIssuer, id)

  @doc """
  Gets a single document_issuer, with country name.

  Raises `Ecto.NoResultsError` if the Document issuer does not exist.

  ## Examples

      iex> get_document_issuer_with_country!(123)
      %{}

      iex> get_document_issuer_with_country!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_document_issuer_with_country!(id :: Ecto.UUID.t()) :: map()
  def get_document_issuer_with_country!(id) when is_bitstring(id) do
    list_document_issuers()
    |> join_country_table()
    |> filter_document_issuers_by_id(id)
    |> select_name_and_country()
    |> Repo.one()
  end

  @doc """
  Constructs an HTML `select` option for a single document issuer entity,
  along with the issuer country name, for use by the `live_select`
  live component.

  Given a current `document_issuer_id`, a reference to the document
  issuer primary key in the `document_issuers` table, calls the
  relevant query, obtaining necessary fields to construct a full,
  unambiguous, document issuer name.

  ## Returns

  Returns a single map:
  ```
  %{
    label: << document_issuer_name >>,
    value: << document_issuer_id (UUID) >>
  ```

  ## Examples

      iex> get_document_issuer_option_for_select_with_country("abc")
      %{label: "...", value: "..."}

      iex> get_document_issuer_option_for_select_with_country(123)
      %{label: "", value: ""}
  """
  @spec get_document_issuer_option_for_select_with_country!(id :: Ecto.UUID.t()) :: %{
          label: String.t(),
          value: String.t()
        }
  def get_document_issuer_option_for_select_with_country!(id) when is_bitstring(id) do
    list_document_issuers()
    |> join_country_table()
    |> filter_document_issuers_by_id(id)
    |> select_document_issuer_options_for_select_name_and_country()
    |> Repo.one()
  end

  def get_document_issuer_option_for_select_with_country!(_id), do: %{label: "", value: ""}

  @doc """
  Creates a document_issuer.

  ## Examples

      iex> create_document_issuer(%{field: value})
      {:ok, %DocumentIssuer{}}

      iex> create_document_issuer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_document_issuer(attrs \\ %{}) do
    %DocumentIssuer{}
    |> DocumentIssuer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a document_issuer.

  ## Examples

      iex> update_document_issuer(document_issuer, %{field: new_value})
      {:ok, %DocumentIssuer{}}

      iex> update_document_issuer(document_issuer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_document_issuer(%DocumentIssuer{} = document_issuer, attrs) do
    document_issuer
    |> DocumentIssuer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a document_issuer.

  ## Examples

      iex> delete_document_issuer(document_issuer)
      {:ok, %DocumentIssuer{}}

      iex> delete_document_issuer(document_issuer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_document_issuer(%DocumentIssuer{} = document_issuer) do
    Repo.delete(document_issuer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking document_issuer changes.

  ## Examples

      iex> change_document_issuer(document_issuer)
      %Ecto.Changeset{data: %DocumentIssuer{}}

  """
  def change_document_issuer(%DocumentIssuer{} = document_issuer, attrs \\ %{}) do
    DocumentIssuer.changeset(document_issuer, attrs)
  end
end
