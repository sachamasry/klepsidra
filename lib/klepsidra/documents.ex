defmodule Klepsidra.Documents do
  @moduledoc """
  The Documents context.
  """

  import Ecto.Query, warn: false
  alias Klepsidra.Repo

  alias Klepsidra.Documents.DocumentType

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
  def list_document_issuers do
    Repo.all(DocumentIssuer)
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
