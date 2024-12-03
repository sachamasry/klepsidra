defmodule Klepsidra.KnowledgeManagement do
  @moduledoc """
  The KnowledgeManagement context.
  """

  import Ecto.Query, warn: false
  alias Klepsidra.Repo

  alias Klepsidra.KnowledgeManagement.Annotation
  alias Klepsidra.KnowledgeManagement.Note

  @doc """
  Returns the list of annotations.

  ## Examples

      iex> list_annotations()
      [%Annotation{}, ...]

  """
  def list_annotations do
    Repo.all(Annotation)
  end

  @doc """
  Returns the list of quotes.

  ## Examples

      iex> list_quotes()
      [%Annotation{}, ...]

  """
  @spec list_quotes() :: [Annotation.t(), ...] | []
  def list_quotes do
    Annotation |> where([a], a.entry_type == "quote") |> Repo.all()
  end

  @doc """
  Returns one random quote.

  ## Examples

      iex> get_random_quote()
      %Annotation{}

  """
  @spec get_random_quote() :: Annotation.t()
  def get_random_quote do
    case list_quotes() do
      [] -> nil
      quote_list -> Enum.random(quote_list)
    end
  end

  @doc """
  Gets a single annotation.

  Raises `Ecto.NoResultsError` if the Annotation does not exist.

  ## Examples

      iex> get_annotation!(123)
      %Annotation{}

      iex> get_annotation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_annotation!(id), do: Repo.get!(Annotation, id)

  @doc """
  Creates a annotation.

  ## Examples

      iex> create_annotation(%{field: value})
      {:ok, %Annotation{}}

      iex> create_annotation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_annotation(attrs \\ %{}) do
    %Annotation{}
    |> Annotation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a annotation.

  ## Examples

      iex> update_annotation(annotation, %{field: new_value})
      {:ok, %Annotation{}}

      iex> update_annotation(annotation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_annotation(%Annotation{} = annotation, attrs) do
    annotation
    |> Annotation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a annotation.

  ## Examples

      iex> delete_annotation(annotation)
      {:ok, %Annotation{}}

      iex> delete_annotation(annotation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_annotation(%Annotation{} = annotation) do
    Repo.delete(annotation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking annotation changes.

  ## Examples

      iex> change_annotation(annotation)
      %Ecto.Changeset{data: %Annotation{}}

  """
  def change_annotation(%Annotation{} = annotation, attrs \\ %{}) do
    Annotation.changeset(annotation, attrs)
  end

  @doc """
  Returns the list of knowledge_management_notes.

  ## Examples

      iex> list_knowledge_management_notes()
      [%Note{}, ...]

  """
  def list_knowledge_management_notes do
    Repo.all(Note)
  end

  @doc """
  Gets a single notes.

  Raises `Ecto.NoResultsError` if the Note does not exist.

  ## Examples

      iex> get_notes!(123)
      %Note{}

      iex> get_notes!(456)
      ** (Ecto.NoResultsError)

  """
  def get_notes!(id), do: Repo.get!(Note, id)

  @doc """
  Creates a notes.

  ## Examples

      iex> create_notes(%{field: value})
      {:ok, %Note{}}

      iex> create_notes(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_notes(attrs \\ %{}) do
    %Note{}
    |> Note.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a notes.

  ## Examples

      iex> update_notes(notes, %{field: new_value})
      {:ok, %Note{}}

      iex> update_notes(notes, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_notes(%Note{} = notes, attrs) do
    notes
    |> Note.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a notes.

  ## Examples

      iex> delete_notes(notes)
      {:ok, %Note{}}

      iex> delete_notes(notes)
      {:error, %Ecto.Changeset{}}

  """
  def delete_notes(%Note{} = notes) do
    Repo.delete(notes)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking notes changes.

  ## Examples

      iex> change_notes(notes)
      %Ecto.Changeset{data: %Note{}}

  """
  def change_notes(%Note{} = notes, attrs \\ %{}) do
    Note.changeset(notes, attrs)
  end

  alias Klepsidra.KnowledgeManagement.NoteTags

  @doc """
  Returns the list of knowledge_management_note_tags.

  ## Examples

      iex> list_knowledge_management_note_tags()
      [%NoteTags{}, ...]

  """
  def list_knowledge_management_note_tags do
    Repo.all(NoteTags)
  end

  @doc """
  Gets a single note_tags.

  Raises `Ecto.NoResultsError` if the Note tags does not exist.

  ## Examples

      iex> get_note_tags!(123)
      %NoteTags{}

      iex> get_note_tags!(456)
      ** (Ecto.NoResultsError)

  """
  def get_note_tags!(id), do: Repo.get!(NoteTags, id)

  @doc """
  Creates a note_tags.

  ## Examples

      iex> create_note_tags(%{field: value})
      {:ok, %NoteTags{}}

      iex> create_note_tags(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_note_tags(attrs \\ %{}) do
    %NoteTags{}
    |> NoteTags.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a note_tags.

  ## Examples

      iex> update_note_tags(note_tags, %{field: new_value})
      {:ok, %NoteTags{}}

      iex> update_note_tags(note_tags, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_note_tags(%NoteTags{} = note_tags, attrs) do
    note_tags
    |> NoteTags.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a note_tags.

  ## Examples

      iex> delete_note_tags(note_tags)
      {:ok, %NoteTags{}}

      iex> delete_note_tags(note_tags)
      {:error, %Ecto.Changeset{}}

  """
  def delete_note_tags(%NoteTags{} = note_tags) do
    Repo.delete(note_tags)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking note_tags changes.

  ## Examples

      iex> change_note_tags(note_tags)
      %Ecto.Changeset{data: %NoteTags{}}

  """
  def change_note_tags(%NoteTags{} = note_tags, attrs \\ %{}) do
    NoteTags.changeset(note_tags, attrs)
  end
end
