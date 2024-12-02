defmodule Klepsidra.Documents do
  @moduledoc """
  The Documents context.
  """

  import Ecto.Query, warn: false
  alias Klepsidra.Repo

  alias Klepsidra.Locations.Country
  alias Klepsidra.Documents.DocumentIssuer
  alias Klepsidra.Documents.DocumentType
  alias Klepsidra.Accounts.User
  alias Klepsidra.Documents.UserDocument

  @doc """
  Query combinator for limiting returned records.
  """
  @spec limit_returned_results(query :: Ecto.Query.t(), limit :: integer()) :: Ecto.Query.t()
  def limit_returned_results(query, limit) do
    from zz in query,
      limit: ^limit
  end

  @spec from_document_types() :: Ecto.Query.t()
  def from_document_types() do
    from(dt in DocumentType, as: :document_types)
  end

  @spec filter_document_types_matching_name(query :: Ecto.Query.t(), name_filter :: String.t()) ::
          Ecto.Query.t()
  def filter_document_types_matching_name(query, name_filter) do
    like_name = "%#{name_filter}%"

    from [document_types: dt] in query,
      where: like(dt.name, ^like_name)
  end

  @spec filter_document_types_by_id(query :: Ecto.Query.t(), id :: Ecto.UUID.t()) ::
          Ecto.Query.t()
  def filter_document_types_by_id(query, id) do
    from [document_types: dt] in query,
      where: dt.id == ^id
  end

  @spec order_by_document_types_name_asc(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def order_by_document_types_name_asc(query) do
    from [document_types: dt] in query,
      order_by: [asc: dt.name]
  end

  @spec select_document_types_options_for_select_name(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def select_document_types_options_for_select_name(query) do
    from [document_types: dt] in query,
      select: %{value: dt.id, label: dt.name}
  end

  @doc """
  Returns the list of document_types.

  ## Examples

      iex> list_document_types(
      [%DocumentType{}, ...]

  """
  def list_document_types do
    Repo.all(DocumentType)
  end

  @spec list_document_types_options_for_select_matching_name(
          name_filter :: String.t(),
          options :: keyword()
        ) ::
          [%{value: Ecto.UUID.t(), label: String.t()}, ...]
  def list_document_types_options_for_select_matching_name(
        name_filter,
        options \\ []
      ) do
    max_result_count = Keyword.get(options, :limit, 25)

    from_document_types()
    |> filter_document_types_matching_name(name_filter)
    |> limit_returned_results(max_result_count)
    |> select_document_types_options_for_select_name()
    |> Repo.all()
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
  Constructs an HTML `select` option for a single document type entity,
  for use by the `live_select` live component.

  Given a current `document_type_id`, a reference to the document
  type primary key in the `document_types` table, calls the
  relevant query, obtaining necessary fields to construct a full,
  unambiguous, document type name.

  ## Returns

  Returns a single map:
  ```
  %{
    label: << document_type_name >>,
    value: << document_type_id (UUID) >>
  ```

  ## Examples

      iex> get_document_type_option_for_select("abc")
      %{label: "...", value: "..."}

      iex> get_document_type_option_for_select(123)
      %{label: "", value: ""}
  """
  @spec get_document_type_option_for_select(id :: Ecto.UUID.t()) :: %{
          label: String.t(),
          value: String.t()
        }
  def get_document_type_option_for_select(""), do: %{label: "", value: ""}

  def get_document_type_option_for_select(id) when is_bitstring(id) do
    from_document_types()
    |> filter_document_types_by_id(id)
    |> select_document_types_options_for_select_name()
    |> Repo.one()
  end

  def get_document_type_option_for_select(_id), do: %{label: "", value: ""}

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

  @doc """
  Returns a simple list of all document_issuers.

  ## Examples

      iex> list_document_issuers()
      [%DocumentIssuer{}, ...]

  """
  def simple_list_document_issuers do
    Repo.all(DocumentIssuer)
  end

  @spec from_document_issuers() :: Ecto.Query.t()
  def from_document_issuers() do
    from(di in DocumentIssuer)
  end

  @spec filter_document_issuers_matching_name(query :: Ecto.Query.t(), name_filter :: String.t()) ::
          Ecto.Query.t()
  def filter_document_issuers_matching_name(query, name_filter) do
    like_name = "%#{name_filter}%"

    from di in query,
      where: like(di.name, ^like_name)
  end

  @spec filter_document_issuers_by_id(query :: Ecto.Query.t(), id :: Ecto.UUID.t()) ::
          Ecto.Query.t()
  def filter_document_issuers_by_id(query, id) do
    from di in query,
      where: di.id == ^id
  end

  @spec order_by_document_issuer_name_asc(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def order_by_document_issuer_name_asc(query) do
    from di in query,
      order_by: [asc: di.name]
  end

  @spec join_country_table(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def join_country_table(query) do
    from di in query,
      left_join: co in Country,
      on: di.country_id == co.iso_3_country_code
  end

  @spec select_name_and_country(query :: Ecto.Query.t()) :: Ecto.Query.t()
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

  @spec select_document_issuer_options_for_select_name(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def select_document_issuer_options_for_select_name(query) do
    from di in query,
      select: %{value: di.id, label: di.name}
  end

  @spec select_document_issuer_options_for_select_name_and_country(query :: Ecto.Query.t()) ::
          Ecto.Query.t()
  def select_document_issuer_options_for_select_name_and_country(query) do
    from [di, co] in query,
      select: %{value: di.id, label: di.name, country_name: co.country_name}
  end

  @spec list_document_issuers_options_for_select_matching_name_with_country(
          name_filter :: String.t(),
          options :: keyword()
        ) ::
          [%{value: Ecto.UUID.t(), label: String.t()}, ...]
  def list_document_issuers_options_for_select_matching_name_with_country(
        name_filter,
        options \\ []
      ) do
    max_result_count = Keyword.get(options, :limit, 25)

    from_document_issuers()
    |> filter_document_issuers_matching_name(name_filter)
    |> join_country_table()
    |> limit_returned_results(max_result_count)
    |> select_document_issuer_options_for_select_name_and_country()
    |> Repo.all()
  end

  @doc """
  Returns a list of document issuers with their country name.

  ## Examples

      iex> list_document_issuers_with_country()
      [%{}, ...]

  """
  @spec list_document_issuers_with_country() :: [%{value: Ecto.UUID.t(), label: String.t()}, ...]
  def list_document_issuers_with_country do
    from_document_issuers()
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
    from_document_issuers()
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
  @spec get_document_issuer_option_for_select_with_country(id :: Ecto.UUID.t()) :: %{
          label: String.t(),
          value: String.t()
        }
  def get_document_issuer_option_for_select_with_country(""), do: %{label: "", value: ""}

  def get_document_issuer_option_for_select_with_country(id) when is_bitstring(id) do
    from_document_issuers()
    |> join_country_table()
    |> filter_document_issuers_by_id(id)
    |> select_document_issuer_options_for_select_name_and_country()
    |> Repo.one()
  end

  def get_document_issuer_option_for_select_with_country(_id), do: %{label: "", value: ""}

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

  @spec from_user_documents() :: Ecto.Query.t()
  def from_user_documents() do
    from(ud in UserDocument, as: :user_documents)
  end

  @spec join_user_document_validity_subquery(query :: Ecto.Query.t(), date :: Date.t()) ::
          Ecto.Query.t()
  def join_user_document_validity_subquery(query, date) when is_struct(date, Date) do
    subquery =
      from(ud_v in UserDocument,
        select: %{
          id: ud_v.id,
          valid:
            fragment(
              """
              CASE
                WHEN ? = false THEN false
                WHEN ? < ? AND ? IS NOT NULL THEN false
                ELSE true
              END
              """,
              ud_v.is_active,
              ud_v.expires_at,
              ^date,
              ud_v.expires_at
            )
        }
      )

    from [user_documents: ud] in query,
      join: ud_v in subquery(subquery),
      as: :user_document_validity,
      on: ud.id == ud_v.id
  end

  @spec join_user_documents_users(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def join_user_documents_users(query) do
    from [user_documents: ud] in query,
      left_join: u in User,
      as: :user,
      on: ud.user_id == u.id
  end

  @spec join_document_types_issuers_and_country_tables(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def join_document_types_issuers_and_country_tables(query) do
    from [user_documents: ud] in query,
      left_join: dt in DocumentType,
      as: :document_type,
      on: ud.document_type_id == dt.id,
      left_join: di in DocumentIssuer,
      as: :document_issuer,
      on: ud.document_issuer_id == di.id,
      left_join: co in Country,
      as: :country,
      on: ud.country_id == co.iso_3_country_code
  end

  @spec filter_user_documents_matching_name(query :: Ecto.Query.t(), name_filter :: String.t()) ::
          Ecto.Query.t()
  def filter_user_documents_matching_name(query, name_filter) do
    like_name = "%#{name_filter}%"

    from [user_documents: ud] in query,
      where: like(ud.name, ^like_name)
  end

  @spec filter_user_documents_by_id(query :: Ecto.Query.t(), id :: Ecto.UUID.t()) ::
          Ecto.Query.t()
  def filter_user_documents_by_id(query, id) do
    from [user_documents: ud] in query,
      where: ud.id == ^id
  end

  @spec filter_user_documents_only_valid(query :: Ecto.Query.t()) ::
          Ecto.Query.t()
  def filter_user_documents_only_valid(query) do
    from [user_documents: ud, user_document_validity: ud_v] in query,
      where: ud_v.valid == true
  end

  @spec order_by_user_documents_name_asc_expiry_desc(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def order_by_user_documents_name_asc_expiry_desc(query) do
    from [user_documents: ud] in query,
      order_by: [asc: ud.name, desc: ud.expires_at]
  end

  @spec order_by_user_documents_validity_name_asc_expiry_desc(query :: Ecto.Query.t()) ::
          Ecto.Query.t()
  def order_by_user_documents_validity_name_asc_expiry_desc(query) do
    from [user_documents: ud, user_document_validity: ud_v] in query,
      order_by: [desc: ud_v.valid, asc: ud.name, desc: ud.expires_at]
  end

  @spec select_document_name_type_issuer_and_country(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def select_document_name_type_issuer_and_country(query) do
    from [
           user_documents: ud,
           document_type: dt,
           document_issuer: di,
           country: co
         ] in query,
         select: %{
           id: ud.id,
           user_id: ud.user_id,
           document_type_id: ud.document_type_id,
           document_type_name: dt.name,
           document_issuer_id: ud.document_issuer_id,
           document_issuer_name: di.name,
           country_id: ud.country_id,
           country_name: co.country_name,
           unique_reference_number: ud.unique_reference_number,
           name: ud.name,
           description: ud.description |> coalesce(""),
           issued_at: ud.issued_at,
           expires_at: ud.expires_at,
           is_active: ud.is_active,
           file_url: ud.file_url
         }
  end

  @spec select_document_name_validity_type_issuer_and_country(query :: Ecto.Query.t()) ::
          Ecto.Query.t()
  def select_document_name_validity_type_issuer_and_country(query) do
    from [
           user_documents: ud,
           user_document_validity: ud_v,
           document_type: dt,
           document_issuer: di,
           country: co
         ] in query,
         select: %{
           id: ud.id,
           user_id: ud.user_id,
           document_type_id: ud.document_type_id,
           document_type_name: dt.name,
           document_issuer_id: ud.document_issuer_id,
           document_issuer_name: di.name,
           country_id: ud.country_id,
           country_name: co.country_name,
           unique_reference_number: ud.unique_reference_number,
           name: ud.name,
           description: ud.description |> coalesce(""),
           issued_at: ud.issued_at,
           expires_at: ud.expires_at,
           valid: ud_v.valid,
           file_url: ud.file_url
         }
  end

  @spec select_user_document_all_fields(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def select_user_document_all_fields(query) do
    from [
           user_documents: ud,
           user_document_validity: ud_v,
           user: u,
           document_type: dt,
           document_issuer: di,
           country: co
         ] in query,
         select: %{
           id: ud.id,
           user_id: ud.user_id,
           user_name: u.user_name,
           document_type_id: ud.document_type_id,
           document_type_name: dt.name,
           document_issuer_id: ud.document_issuer_id,
           document_issuer_name: di.name,
           country_id: ud.country_id,
           country_name: co.country_name,
           unique_reference_number: ud.unique_reference_number,
           name: ud.name,
           description: ud.description |> coalesce(""),
           issued_at: ud.issued_at,
           expires_at: ud.expires_at,
           is_active: ud.is_active,
           invalidation_reason: ud.invalidation_reason,
           valid: ud_v.valid,
           file_url: ud.file_url,
           custom_buffer_time_days: ud.custom_buffer_time_days
         }
  end

  @spec select_user_documents_options_for_select_name(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def select_user_documents_options_for_select_name(query) do
    from [user_documents: ud, country: co] in query,
      select: %{
        value: ud.id,
        label:
          fragment(
            "concat(?, ' (', ?, ') ', ?)",
            ud.name,
            co.country_name,
            ud.unique_reference_number
          )
      }
  end

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
  Returns a list of user documents with the document type,
  issuer and country names.

  ## Examples

      iex> list_user_documents_with_document_type_issuer_and_country()
      [%{}, ...]

  """
  @spec list_user_documents_with_document_type_issuer_and_country(options :: keyword()) ::
          [map(), ...]
  def list_user_documents_with_document_type_issuer_and_country(options \\ []) do
    date = Keyword.get(options, :date, Date.utc_today())

    from_user_documents()
    |> join_user_document_validity_subquery(date)
    |> join_document_types_issuers_and_country_tables()
    |> order_by_user_documents_validity_name_asc_expiry_desc()
    |> select_document_name_validity_type_issuer_and_country()
    |> Repo.all()
  end

  @spec list_user_documents_options_for_select_matching_name(
          name_filter :: String.t(),
          options :: keyword()
        ) ::
          [%{value: Ecto.UUID.t(), label: String.t()}, ...]

  def list_user_documents_options_for_select_matching_name(name_filter, options \\ [])

  def list_user_documents_options_for_select_matching_name(name_filter, options)
      when is_bitstring(name_filter) do
    max_result_count = Keyword.get(options, :limit, 25)

    from_user_documents()
    |> join_document_types_issuers_and_country_tables()
    |> filter_user_documents_matching_name(name_filter)
    |> limit_returned_results(max_result_count)
    |> select_user_documents_options_for_select_name()
    |> Repo.all()
  end

  def list_user_documents_options_for_select_matching_name(_, _), do: [%{value: "", label: ""}]

  @spec list_user_documents_options_for_select_valid_matching_name(
          name_filter :: String.t(),
          options :: keyword()
        ) ::
          [%{value: Ecto.UUID.t(), label: String.t()}, ...]

  def list_user_documents_options_for_select_valid_matching_name(name_filter, options \\ [])

  def list_user_documents_options_for_select_valid_matching_name(name_filter, options)
      when is_bitstring(name_filter) do
    date = Keyword.get(options, :date, Date.utc_today())
    max_result_count = Keyword.get(options, :limit, 25)

    from_user_documents()
    |> join_user_document_validity_subquery(date)
    |> join_document_types_issuers_and_country_tables()
    |> filter_user_documents_only_valid()
    |> filter_user_documents_matching_name(name_filter)
    |> limit_returned_results(max_result_count)
    |> select_user_documents_options_for_select_name()
    |> Repo.all()
  end

  def list_user_documents_options_for_select_valid_matching_name(_, _),
    do: [%{value: "", label: ""}]

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
  Returns a single user document, with its document type, issuer and country name.

  ## Examples

      iex> get_user_document_with_document_type_issuer_and_country(id)
      [%{}, ...]

  """
  @spec get_user_document_with_document_type_issuer_and_country(id :: Ecto.UUID.t()) :: [
          map(),
          ...
        ]
  def get_user_document_with_document_type_issuer_and_country(id) when is_bitstring(id) do
    from_user_documents()
    |> join_document_types_issuers_and_country_tables()
    |> filter_user_documents_by_id(id)
    |> select_document_name_type_issuer_and_country()
    |> Repo.one()
  end

  @doc """
  Constructs an HTML `select` option for a single user document,
  for use by the `live_select` live component.

  Given a current `user_document_id`, a reference to the document
  primary key in the `user_documents` table, calls the relevant query,
  obtaining necessary fields to construct a full, unambiguous, document name.

  ## Returns

  Returns a single map:
  ```
  %{
    label: << user_document_name >>,
    value: << user_document_id (UUID) >>
  ```

  ## Examples

      iex> get_user_document_option_for_select("abc")
      %{label: "...", value: "..."}

      iex> get_user_document_option_for_select(123)
      %{label: "", value: ""}
  """
  @spec get_user_document_option_for_select(id :: Ecto.UUID.t()) :: %{
          label: String.t(),
          value: String.t()
        }
  def get_user_document_option_for_select(""), do: %{label: "", value: ""}

  def get_user_document_option_for_select(id) when is_bitstring(id) do
    from_user_documents()
    |> join_document_types_issuers_and_country_tables()
    |> filter_user_documents_by_id(id)
    |> select_user_documents_options_for_select_name()
    |> Repo.one()
  end

  def get_user_document_option_for_select(_id), do: %{label: "", value: ""}

  @doc """
  Returns a single user document, with all joins performed and all fields returned.

  ## Examples

      iex> list_document_issuers_with_all_fields(id)
      [%{}, ...]

  """
  @spec get_user_document_with_all_fields(id :: Ecto.UUID.t()) :: [
          map(),
          ...
        ]
  def get_user_document_with_all_fields(id, options \\ []) when is_bitstring(id) do
    date = Keyword.get(options, :date, Date.utc_today())

    from_user_documents()
    |> join_user_document_validity_subquery(date)
    |> join_user_documents_users()
    |> join_document_types_issuers_and_country_tables()
    |> filter_user_documents_by_id(id)
    |> select_user_document_all_fields()
    |> Repo.one()
  end

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
end
