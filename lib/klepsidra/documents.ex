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
end
