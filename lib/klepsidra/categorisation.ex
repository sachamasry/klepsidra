defmodule Klepsidra.Categorisation do
  @moduledoc """
  The Categorisation context provides a way to categorise entities within the
  application.

  A general-purpose _tagging_ module provides a record of all tags used for various entities.
  Presently, tagging is only used in activity timers so that users can simply categorise
  their timed activities, to help filter activities by category, to search for timers, and to
  make it easier to collate timers with client invoicing in mind.

  Tagging activity timers requires a many-to-many relationship between timers and
  tags, which is recorded in the `timer_tags` table.
  """

  import Ecto.Query, warn: false
  alias Klepsidra.Repo

  alias Klepsidra.Categorisation.Tag
  alias Klepsidra.Categorisation.TimerTags
  alias Klepsidra.Categorisation.ProjectTags
  alias Klepsidra.Categorisation.JournalEntryTags

  @doc """
  Returns the list of tags.

  ## Examples

      iex> list_tags()
      [%Tag{}, ...]

  """
  def list_tags do
    Tag |> order_by(asc: fragment("name COLLATE NOCASE")) |> Repo.all()
  end

  @doc """
  Gets a single tag.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_tag!(123)
      %Tag{}

      iex> get_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tag!(id), do: Repo.get!(Tag, id)

  @doc """
  Gets multiple tags.

  Raises `Ecto.NoResultsError` if the Tag id is not a proper UUID.

  ## Examples

      iex> get_tags!([123, 789])
      %Tag{}

      iex> get_tag!([])
      []

      iex> get_tag!([""])
      ** (Ecto.Query.CastError)

  """
  @spec get_tags!(id_list :: [Ecto.UUID.t(), ...]) :: [Tag.t(), ...] | []
  def get_tags!(id_list) when is_list(id_list) do
    Repo.all(from(t in Tag, where: t.id in ^id_list))
  end

  @doc """
  Gets multiple tags, sorted by tag name.

  Raises `Ecto.NoResultsError` if the Tag id is not a proper UUID.

  ## Examples

      iex> get_tags_sorted!([123, 789])
      %Tag{}

      iex> get_tag_sorted!([])
      []

      iex> get_tag_sorted!([""])
      ** (Ecto.Query.CastError)

  """
  @spec get_tags_sorted!(id_list :: [Ecto.UUID.t(), ...]) :: [Tag.t(), ...] | []
  def get_tags_sorted!(id_list) when is_list(id_list) do
    Repo.all(
      from(
        t in Tag,
        where: t.id in ^id_list,
        order_by: [asc: t.name]
      )
    )
  end

  @doc """
  Simple search for tags defined in the system, performing a prefix filter only.

  This search takes in the `search_phrase`, and after converting it to lowercase,
  compares it against a list of similarly lowercased tag names (`name` field), from the
  database. The comparison checks filters all tags that start with the normalised
  search phrase.

  ## Examples

      iex> search_tags_by_name_prefix("hello")
      [%Tag{}, ...]
  """
  @spec search_tags_by_name_prefix(String.t()) :: [Tag.t(), ...]
  def search_tags_by_name_prefix(search_phrase) do
    search_phrase = String.downcase(search_phrase)

    Klepsidra.Categorisation.list_tags()
    |> Enum.filter(fn %{name: name} ->
      String.starts_with?(String.downcase(name), search_phrase)
    end)
  end

  @doc """
  Search for tags using a `LIKE` wildcard search.
  """
  @spec search_tags_by_name_content(search_phrase :: String.t()) :: [Tag.t(), ...]
  def search_tags_by_name_content(search_phrase) when is_bitstring(search_phrase) do
    search_fragment = "%#{String.downcase(search_phrase)}%"

    query =
      from(t in Tag,
        where: like(t.name, ^search_fragment),
        order_by: [asc: fragment("lower(?)", t.name)]
      )

    Repo.all(query)
  end

  @doc """
  Creates a tag.

  ## Examples

      iex> create_tag(%{field: value})
      {:ok, %Tag{}}

      iex> create_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_tag(attrs :: map()) :: {:ok, Tag.t()} | {:error, any()}
  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a tag if it doesn't exist, otherwise gets and returns a tag
  matching the name provided.

  ## Examples

      iex> create_or_find_tag(%{name: good_name})
      %Tag{}

      iex> create_or_find_tag(%{field: existing_name})
      %Tag{}

  """
  @spec create_or_find_tag(attrs :: map()) :: Tag.t()
  def create_or_find_tag(%{name: "" <> name} = attrs) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, tag} ->
        tag

      {:error, _changeset} ->
        Repo.get_by(Tag, name: name)

      _ ->
        Repo.get_by(Tag, name: name)
    end
  end

  def create_or_find_tag(_), do: nil

  @doc """
  Updates a tag.

  ## Examples

      iex> update_tag(tag, %{field: new_value})
      {:ok, %Tag{}}

      iex> update_tag(tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tag(%Tag{} = tag, attrs) do
    tag
    |> Tag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tag.

  ## Examples

      iex> delete_tag(tag)
      {:ok, %Tag{}}

      iex> delete_tag(tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tag(%Tag{} = tag) do
    Repo.delete(tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag changes.

  ## Examples

      iex> change_tag(tag)
      %Ecto.Changeset{data: %Tag{}}

  """
  def change_tag(%Tag{} = tag, attrs \\ %{}) do
    Tag.changeset(tag, attrs)
  end

  @doc """
  Attach a single tag to a timer. Checks if the tag is already associated
  with the timer, only adding it if it’s missing.

  ## Examples

      iex> add_timer_tag(%Timer{}, %Tag{})
      {:ok, :inserted}

      iex> add_timer_tag(%Timer{}, %Tag{})
      {:ok, :already_exists}

      iex> add_timer_tag(%Timer{}, %Tag{})
      {:error, :insert_failed}

  """
  @spec add_timer_tag(timer_id :: Ecto.UUID.t(), tag_id :: Ecto.UUID.t()) ::
          {:ok, :inserted}
          | {:ok, :already_exists}
          | {:error, :insert_failed}
          | {:error, :timer_is_nil}
  def add_timer_tag(nil, _tag_id), do: {:error, :timer_is_nil}

  def add_timer_tag(timer_id, tag_id) do
    now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    # Check if the tag is already associated with the timer
    existing_association =
      Repo.get_by(TimerTags, timer_id: timer_id, tag_id: tag_id)

    # Repo.update(changeset)
    if existing_association do
      {:ok, :already_exists}
    else
      # Insert a new association with timestamps
      timer_tag_entry = %TimerTags{
        timer_id: timer_id,
        tag_id: tag_id,
        inserted_at: now,
        updated_at: now
      }

      case Repo.insert(timer_tag_entry) do
        {:ok, _} -> {:ok, :inserted}
        {:error, _} -> {:error, :insert_failed}
      end
    end
  end

  @doc """
  Deletes a timer's tag association.

  ## Examples

      iex> delete_timer_tag(%Timer(), %Tag())
      {:ok, :deleted}

      iex> delete_timer_tag(%Timer(), %Tag())
      {:error, :not_found}

      iex> delete_timer_tag(%Timer(), %Tag())
      {:error, :delete_failed}

  """
  @spec delete_timer_tag(timer_id :: Ecto.UUID.t(), tag_id :: Ecto.UUID.t()) ::
          {:ok, :deleted} | {:error, :not_found} | {:error, :delete_failed}
  def delete_timer_tag(timer_id, tag_id) do
    # Execute the delete operation on the "timer_tags" table
    case Repo.get_by(TimerTags, timer_id: timer_id, tag_id: tag_id) do
      # Record not found
      nil ->
        {:error, :not_found}

      timer_tag ->
        case Repo.delete(timer_tag) do
          {:ok, _} -> {:ok, :deleted}
          {:error, _} -> {:error, :delete_failed}
        end
    end
  end

  @doc """
  Gets a single timer tag record.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_timer_tag!("timer_id", "tag_id")
      %TimerTags{}

      iex> get_timer_tag!("", "")
      ** (Ecto.NoResultsError)

  """
  @spec get_timer_tag!(timer_id :: Ecto.UUID.t(), tag_id :: Ecto.UUID.t()) :: TimerTags.t()
  def get_timer_tag!(timer_id, tag_id),
    do: Repo.get_by!(TimerTags, timer_id: timer_id, tag_id: tag_id)

  @doc """
  Attach a single tag to a project. Checks if the tag is already associated
  with the project, only adding it if it’s missing.

  ## Examples

      iex> add_project_tag(%Project{}, %Tag{})
      {:ok, :inserted}

      iex> add_project_tag(%Project{}, %Tag{})
      {:ok, :already_exists}

      iex> add_project_tag(%Project{}, %Tag{})
      {:error, :insert_failed}

  """
  @spec add_project_tag(project_id :: Ecto.UUID.t(), tag_id :: Ecto.UUID.t()) ::
          {:ok, :inserted}
          | {:ok, :already_exists}
          | {:error, :insert_failed}
          | {:error, :project_is_nil}
  def add_project_tag(nil, _tag_id), do: {:error, :project_is_nil}

  def add_project_tag(project_id, tag_id) do
    now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    # Check if the tag is already associated with the project
    existing_association =
      Repo.get_by(ProjectTags, project_id: project_id, tag_id: tag_id)

    # Repo.update(changeset)
    if existing_association do
      {:ok, :already_exists}
    else
      # Insert a new association with timestamps
      project_tag_entry = %ProjectTags{
        project_id: project_id,
        tag_id: tag_id,
        inserted_at: now,
        updated_at: now
      }

      case Repo.insert(project_tag_entry) do
        {:ok, _} -> {:ok, :inserted}
        {:error, _} -> {:error, :insert_failed}
      end
    end
  end

  @doc """
  Deletes a project's tag association.

  ## Examples

      iex> delete_project_tag(%Project(), %Tag())
      {:ok, :deleted}

      iex> delete_project_tag(%Project(), %Tag())
      {:error, :not_found}

      iex> delete_project_tag(%Project(), %Tag())
      {:error, :unexpected_result}

  """
  @spec delete_project_tag(project_id :: Ecto.UUID.t(), tag_id :: Ecto.UUID.t()) ::
          {:ok, :deleted} | {:error, :not_found} | {:error, :delete_failed}
  def delete_project_tag(project_id, tag_id) do
    # Execute the delete operation on the "project_tags" table
    case Repo.get_by(ProjectTags, project_id: project_id, tag_id: tag_id) do
      # Record not found
      nil ->
        {:error, :not_found}

      project_tag ->
        case Repo.delete(project_tag) do
          {:ok, _} -> {:ok, :deleted}
          {:error, _} -> {:error, :delete_failed}
        end
    end
  end

  @doc """
  Gets a single project tag.

  Raises `Ecto.NoResultsError` if the Project tag does not exist.

  ## Examples

      iex> get_project_tag!(123)
      %ProjectTags{}

      iex> get_project_tag!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_project_tag!(project_id :: Ecto.UUID.t(), tag_id :: Ecto.UUID.t()) :: ProjectTags.t()
  def get_project_tag!(project_id, tag_id),
    do: Repo.get!(ProjectTags, project_id: project_id, tag_id: tag_id)

  @doc """
  Attach a single tag to a journal entry. Checks if the tag is already associated
  with the entry, only adding it if it’s missing.

  ## Examples

      iex> add_journal_entry_tag(%JournalEntry{}, %Tag{})
      {:ok, :inserted}

      iex> add_journal_entry_tag(%JournalEntry{}, %Tag{})
      {:ok, :already_exists}

      iex> add_journal_entry_tag(%JournalEntry{}, %Tag{})
      {:error, :insert_failed}

  """
  @spec add_journal_entry_tag(journal_entry_id :: Ecto.UUID.t(), tag_id :: Ecto.UUID.t()) ::
          {:ok, :inserted}
          | {:ok, :already_exists}
          | {:error, :insert_failed}
          | {:error, :journal_entry_is_nil}
  def add_journal_entry_tag(nil, _tag_id), do: {:error, :journal_entry_is_nil}

  def add_journal_entry_tag(journal_entry_id, tag_id) do
    now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    # Check if the tag is already associated with the journal entry
    existing_association =
      Repo.get_by(JournalEntryTags, journal_entry_id: journal_entry_id, tag_id: tag_id)

    # Repo.update(changeset)
    if existing_association do
      {:ok, :already_exists}
    else
      # Insert a new association with timestamps
      journal_entry_tag_entry = %JournalEntryTags{
        journal_entry_id: journal_entry_id,
        tag_id: tag_id,
        inserted_at: now,
        updated_at: now
      }

      case Repo.insert(journal_entry_tag_entry) do
        {:ok, _} -> {:ok, :inserted}
        {:error, _} -> {:error, :insert_failed}
      end
    end
  end

  @doc """
  Deletes a journal entry's tag association.

  ## Examples

      iex> delete_journal_entry_tag(%JournalEntry(), %Tag())
      {:ok, :deleted}

      iex> delete_journal_entry_tag(%JournalEntry(), %Tag())
      {:error, :not_found}

      iex> delete_journal_entry_tag(%JournalEntry(), %Tag())
      {:error, :unexpected_result}

  """
  @spec delete_journal_entry_tag(journal_entry_id :: Ecto.UUID.t(), tag_id :: Ecto.UUID.t()) ::
          {:ok, :deleted} | {:error, :not_found} | {:error, :delete_failed}
  def delete_journal_entry_tag(journal_entry_id, tag_id) do
    # Execute the delete operation on the "journal_entry_tags" table
    case Repo.get_by(JournalEntryTags, journal_entry_id: journal_entry_id, tag_id: tag_id) do
      # Record not found
      nil ->
        {:error, :not_found}

      journal_entry_tag ->
        case Repo.delete(journal_entry_tag) do
          {:ok, _} -> {:ok, :deleted}
          {:error, _} -> {:error, :delete_failed}
        end
    end
  end
end
