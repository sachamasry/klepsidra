defmodule Klepsidra.KnowledgeManagement do
  @moduledoc """
  The KnowledgeManagement context.
  """

  import Ecto.Query, warn: false
  alias Klepsidra.Repo

  alias Klepsidra.KnowledgeManagement.Annotation
  alias Klepsidra.KnowledgeManagement.Note
  alias Klepsidra.KnowledgeManagement.NoteTags
  alias Klepsidra.KnowledgeManagement.NoteSearch
  alias Klepsidra.KnowledgeManagement.NoteTags
  alias Klepsidra.Categorisation.Tag

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
  Gets a single note.

  Raises `Ecto.NoResultsError` if the Note does not exist.

  ## Examples

      iex> get_note!(123)
      %Note{}

      iex> get_note!(456)
      ** (Ecto.NoResultsError)

  """
  def get_note!(id), do: Repo.get!(Note, id)

  @doc """
  Creates a note.

  ## Examples

      iex> create_note(%{field: value})
      {:ok, %Note{}}

      iex> create_note(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_note(attrs \\ %{}) do
    %Note{}
    |> Note.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a note.

  ## Examples

      iex> update_note(note, %{field: new_value})
      {:ok, %Note{}}

      iex> update_note(note, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_note(%Note{} = note, attrs) do
    note
    |> Note.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a note.

  ## Examples

      iex> delete_note(notes)
      {:ok, %Note{}}

      iex> delete_note(notes)
      {:error, %Ecto.Changeset{}}

  """
  def delete_note(%Note{} = note) do
    Repo.delete(note)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking note changes.

  ## Examples

      iex> change_notes(note)
      %Ecto.Changeset{data: %Note{}}

  """
  def change_note(%Note{} = note, attrs \\ %{}) do
    Note.changeset(note, attrs)
  end

  @doc """
  Returns the list of knowledge management note tags.

  ## Examples

      iex> list_knowledge_management_note_tags()
      [%NoteTags{}, ...]

  """
  def list_knowledge_management_note_tags do
    Repo.all(NoteTags)
  end

  @doc """
  Gets a single note tag.

  Raises `Ecto.NoResultsError` if the Note tag does not exist.

  ## Examples

      iex> get_note_tag!(123)
      %NoteTags{}

      iex> get_note_tags!(456)
      ** (Ecto.NoResultsError)

  """
  def get_note_tag!(id), do: Repo.get!(NoteTag, id)

  # @doc """
  # Creates a note tag.

  # ## Examples

  #     iex> create_note_tag(%{field: value})
  #     {:ok, %NoteTags{}}

  #     iex> create_note_tag(%{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def create_note_tag(attrs \\ %{}) do
  #   %NoteTags{}
  #   |> NoteTags.changeset(attrs)
  #   |> Repo.insert()
  # end

  @doc """
  Attach a single tag to a knowledge management note. Checks if
  the tag is already associated with the note, only adding it
  if it’s missing.

  ## Examples

      iex> add_knowledge_management_note_tag(%Note{}, %Tag{})
      {:ok, :inserted}

      iex> add_knowledge_management_note_tag(%Note{}, %Tag{})
      {:ok, :already_exists}

      iex> add_knowledge_management_note_tag(%Note{}, %Tag{})
      {:error, :insert_failed}

  """
  @spec add_knowledge_management_note_tag(note_id :: Ecto.UUID.t(), tag_id :: Ecto.UUID.t()) ::
          {:ok, :inserted}
          | {:ok, :already_exists}
          | {:error, :insert_failed}
          | {:error, :note_is_nil}
  def add_knowledge_management_note_tag(nil, _tag_id), do: {:error, :note_is_nil}

  def add_knowledge_management_note_tag(note_id, tag_id) do
    now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    # Check if the tag is already associated with the note entry
    existing_association =
      Repo.get_by(NoteTags, note_id: note_id, tag_id: tag_id)

    # Repo.update(changeset)
    if existing_association do
      {:ok, :already_exists}
    else
      # Insert a new association with timestamps
      note_tag_entry = %NoteTags{
        note_id: note_id,
        tag_id: tag_id,
        inserted_at: now,
        updated_at: now
      }

      case Repo.insert(note_tag_entry) do
        {:ok, _} -> {:ok, :inserted}
        {:error, _} -> {:error, :insert_failed}
      end
    end
  end

  @doc """
  Deletes a note's tag association.

  ## Examples

      iex> delete_knowledge_management_note_tag(%Note(), %Tag())
      {:ok, :deleted}

      iex> delete_knowledge_management_note_tag(%Note(), %Tag())
      {:error, :not_found}

      iex> delete_knowledge_management_note_tag(%Note(), %Tag())
      {:error, :unexpected_result}

  """
  @spec delete_knowledge_management_note_tag(note_id :: Ecto.UUID.t(), tag_id :: Ecto.UUID.t()) ::
          {:ok, :deleted} | {:error, :not_found} | {:error, :delete_failed}
  def delete_knowledge_management_note_tag(note_id, tag_id) do
    # Execute the delete operation on the "note_tags" table
    case Repo.get_by(NoteTags, note_id: note_id, tag_id: tag_id) do
      # Record not found
      nil ->
        {:error, :not_found}

      note_tag ->
        case Repo.delete(note_tag) do
          {:ok, _} -> {:ok, :deleted}
          {:error, _} -> {:error, :delete_failed}
        end
    end
  end

  # @doc """
  # Updates a note tag.

  # ## Examples

  #     iex> update_note_tag(note_tag, %{field: new_value})
  #     {:ok, %NoteTags{}}

  #     iex> update_note_tag(note_tag, %{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def update_note_tag(%NoteTags{} = note_tag, attrs) do
  #   note_tag
  #   |> NoteTags.changeset(attrs)
  #   |> Repo.update()
  # end

  @doc """
  Deletes a note tag.

  ## Examples

      iex> delete_note_tags(note_tags)
      {:ok, %NoteTags{}}

      iex> delete_note_tags(note_tags)
      {:error, %Ecto.Changeset{}}

  """
  def delete_note_tag(%NoteTags{} = note_tag) do
    Repo.delete(note_tag)
  end

  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking note tag changes.

  # ## Examples

  #     iex> change_note_tag(note_tag)
  #     %Ecto.Changeset{data: %NoteTags{}}

  # """
  # def change_note_tags(%NoteTag{} = note_tag, attrs \\ %{}) do
  #   NoteTags.changeset(note_tag, attrs)
  # end

  alias Klepsidra.KnowledgeManagement.NoteSearch

  @doc """
  Returns the list of knowledge_management_notes_search.

  ## Examples

      iex> list_knowledge_management_notes_search()
      [%NoteSearch{}, ...]

  """
  def list_knowledge_management_notes_search do
    Repo.all(NoteSearch)
  end

  @doc """
  Search knowledge management notes using full-text search.

  ## Examples

      iex> search_notes("hello")
      [%Klepsidra.KnowledgeManagement.NoteSearch{}, ...]

  """

  # def search_notes(search_phrase) do
  #   from(ns in NoteSearch,
  #     select: [:rank, :id, :title, :content, :summary, :tags],
  #     where: fragment("knowledge_management_notes_search MATCH ?", ^search_phrase),
  #     order_by: [asc: :rank]
  #   )
  #   |> Repo.all()
  # end

  def search_notes_and_highlight(search_phrase) do
    from(ns in NoteSearch,
      select: fragment("highlight(knowledge_management_notes_search, 0, \'<b>\', \'</b>\')"),
      where: fragment("knowledge_management_notes_search MATCH ?", ^search_phrase),
      order_by: [asc: :rank]
    )
    |> Repo.all()
  end

  @spec search_notes_and_highlight_snippet(search_phrase :: String.t()) ::
          [%{id: Ecto.UUID.t(), result: String.t()}, ...]
  def search_notes_and_highlight_snippet(search_phrase) do
    from(ns in NoteSearch,
      select: %{
        id: ns.note_id,
        title: ns.title,
        summary: ns.summary,
        result:
          fragment(
            "snippet(knowledge_management_notes_search, -1, \'<span class=\"font-semibold group-hover:font-bold underline decoration-peach-fuzz-600 group-hover:decoration-peach-fuzz-50 text-peach-fuzz-600 group-hover:text-peach-fuzz-50\">\', \'</span>\', \'…\', 64)"
          )
      },
      where: fragment("knowledge_management_notes_search MATCH ?", ^search_phrase),
      order_by: [asc: :rank]
    )
    |> Repo.all()
  end

  @spec from_knowledge_management_notes() :: Ecto.Query.t()
  def from_knowledge_management_notes() do
    from(n in Note, as: :notes)
  end

  @spec join_knowledge_management_note_tags_and_tags_tables(query :: Ecto.Query.t()) ::
          Ecto.Query.t()
  def join_knowledge_management_note_tags_and_tags_tables(query) do
    from [notes: n] in query,
      left_join: nt in NoteTags,
      on: n.id == nt.note_id,
      left_join: t in Tag,
      on: nt.tag_id == t.id,
      as: :tags
  end

  @spec select_knowledge_management_notes_for_fts(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def select_knowledge_management_notes_for_fts(query) do
    from [notes: n, tags: t] in query,
      group_by: [n.id, n.title, n.content, n.summary],
      select: %{
        note_id: n.id,
        title: n.title,
        content: n.content,
        summary: n.summary,
        tags: fragment("GROUP_CONCAT(?, ' ⸱ ')", t.name)
      }
  end

  @spec list_knowledge_management_notes_for_fts() ::
          [%{value: Ecto.UUID.t(), label: String.t()}, ...]
  def list_knowledge_management_notes_for_fts() do
    from_knowledge_management_notes()
    |> join_knowledge_management_note_tags_and_tags_tables()
    |> select_knowledge_management_notes_for_fts()
    |> Repo.all()
  end

  @spec insert_knowledge_management_notes_into_fts() :: {integer(), nil}
  def insert_knowledge_management_notes_into_fts() do
    query =
      from_knowledge_management_notes()
      |> join_knowledge_management_note_tags_and_tags_tables()
      |> select_knowledge_management_notes_for_fts()

    Repo.insert_all(NoteSearch, query)
  end

  # INSERT INTO knowledge_management_notes_search(note_id, title, content, summary, tags)
  # SELECT kmn.id, kmn.title, kmn.content, kmn.summary, GROUP_CONCAT(t.name, ' ⸱ ') tags

  # LEFT JOIN knowledge_management_note_tags kmnt 
  # ON kmn.id = kmnt.note_id 
  # LEFT JOIN tags t 
  # ON kmnt.tag_id = t.id 

  # GROUP BY kmn.id, kmn.title, kmn.content, kmn.summary 

  alias Klepsidra.KnowledgeManagement.RelationshipType

  @doc """
  Returns the list of knowledge_management_relationship_types.

  ## Examples

      iex> list_knowledge_management_relationship_types()
      [%RelationshipType{}, ...]

  """
  def list_knowledge_management_relationship_types do
    RelationshipType |> order_by(asc: :name) |> Repo.all()
  end

  @doc """
  Gets a single relationship_type.

  Raises `Ecto.NoResultsError` if the Relationship type does not exist.

  ## Examples

      iex> get_relationship_type!(123)
      %RelationshipType{}

      iex> get_relationship_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_relationship_type!(id), do: Repo.get!(RelationshipType, id)

  @doc """
  Creates a relationship_type.

  ## Examples

      iex> create_relationship_type(%{field: value})
      {:ok, %RelationshipType{}}

      iex> create_relationship_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_relationship_type(attrs \\ %{}) do
    %RelationshipType{}
    |> RelationshipType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a relationship_type.

  ## Examples

      iex> update_relationship_type(relationship_type, %{field: new_value})
      {:ok, %RelationshipType{}}

      iex> update_relationship_type(relationship_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_relationship_type(%RelationshipType{} = relationship_type, attrs) do
    relationship_type
    |> RelationshipType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a relationship_type.

  ## Examples

      iex> delete_relationship_type(relationship_type)
      {:ok, %RelationshipType{}}

      iex> delete_relationship_type(relationship_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_relationship_type(%RelationshipType{} = relationship_type) do
    Repo.delete(relationship_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking relationship_type changes.

  ## Examples

      iex> change_relationship_type(relationship_type)
      %Ecto.Changeset{data: %RelationshipType{}}

  """
  def change_relationship_type(%RelationshipType{} = relationship_type, attrs \\ %{}) do
    RelationshipType.changeset(relationship_type, attrs)
  end

  alias Klepsidra.KnowledgeManagement.NoteRelation

  @doc """
  Returns the list of knowledge_management_note_relations.

  ## Examples

      iex> list_knowledge_management_note_relations()
      [%NoteRelation{}, ...]

  """
  def list_knowledge_management_note_relations do
    Repo.all(NoteRelation)
  end

  @doc """
  Gets a single note relation.

  Raises `Ecto.NoResultsError` if the note relation does not exist.

  ## Examples

      iex> get_note_relation!(123, 234, 345)
      %NoteRelation{}

      iex> get_note_relation!(456)
      ** (Ecto.NoResultsError)

  """

  @spec get_note_relation!(
          source_note_id :: Ecto.UUID.t(),
          target_note_id :: Ecto.UUID.t(),
          relationship_type_id :: Ecto.UUID.t()
        ) :: [NoteRelation.t(), ...]
  def get_note_relation!(source_note_id, target_note_id, relationship_type_id) do
    query =
      from nr in NoteRelation,
        where:
          nr.source_note_id == ^source_note_id and nr.target_note_id == ^target_note_id and
            nr.relationship_type_id == ^relationship_type_id

    Repo.one(query)
  end

  @doc """
  Creates a new note relation.

  ## Examples

      iex> create_note_relation(%{field: value})
      {:ok, %NoteRelation{}}

      iex> create_note_relation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_note_relation(attrs :: map()) ::
          {:ok, NoteRelation.t()} | {:error, Ecto.Changeset.t()}
  def create_note_relation(attrs \\ %{}) do
    %NoteRelation{}
    |> NoteRelation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a note_relation.

  ## Examples

      iex> update_note_relation(note_relation, %{field: new_value})
      {:ok, %NoteRelation{}}

      iex> update_note_relation(note_relation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_note_relation(%NoteRelation{} = note_relation, attrs) do
    note_relation
    |> NoteRelation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a note_relation.

  ## Examples

      iex> delete_note_relation(note_relation)
      {:ok, %NoteRelation{}}

      iex> delete_note_relation(note_relation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_note_relation(%NoteRelation{} = note_relation) do
    Repo.delete(note_relation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking note_relation changes.

  ## Examples

      iex> change_note_relation(note_relation)
      %Ecto.Changeset{data: %NoteRelation{}}

  """
  def change_note_relation(%NoteRelation{} = note_relation, attrs \\ %{}) do
    NoteRelation.changeset(note_relation, attrs)
  end
end
