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
  alias Klepsidra.TimeTracking.Timer
  alias Klepsidra.DynamicCSS

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
  Creates a tag.

  ## Examples

      iex> create_tag(%{field: value})
      {:ok, %Tag{}}

      iex> create_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tag(attrs \\ %{}) do
    case Repo.insert(%Tag{} |> Tag.changeset(attrs)) do
      {:ok, tag} ->
        # Fetch all tags and regenerate the CSS
        tags = list_tags()
        DynamicCSS.generate_tag_styles(tags)
        {:ok, tag}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates a tag.

  ## Examples

      iex> update_tag(tag, %{field: new_value})
      {:ok, %Tag{}}

      iex> update_tag(tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tag(%Tag{} = tag, attrs) do
    case Repo.update(tag |> Tag.changeset(attrs)) do
      {:ok, tag} ->
        # Fetch all tags and regenerate the CSS
        tags = list_tags()
        DynamicCSS.generate_tag_styles(tags)
        {:ok, tag}

      {:error, changeset} ->
        {:error, changeset}
    end
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
    case Repo.delete(tag) do
      {:ok, tag} ->
        tags = list_tags()
        DynamicCSS.generate_tag_styles(tags)
        {:ok, tag}

      {:error, changeset} ->
        {:error, changeset}
    end
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

  def add_timer_tag(nil, _tag_id), do: {:error, :timer_is_nil}

  def add_timer_tag(timer_id, tag_id) do
    now = DateTime.utc_now()

    # Check if the tag is already associated with the timer
    existing_association =
      Repo.one(
        from(tt in "timer_tags",
          where: tt.timer_id == ^timer_id and tt.tag_id == ^tag_id,
          select: %{timer_id: tt.timer_id, tag_id: tt.tag_id}
        )
      )

    # Repo.update(changeset)
    if existing_association do
      {:ok, :already_exists}
    else
      # Insert a new association with timestamps
      timer_tag_entry = %{
        timer_id: timer_id,
        tag_id: tag_id,
        inserted_at: now,
        updated_at: now
      }

      case Repo.insert_all("timer_tags", [timer_tag_entry]) do
        {1, _} -> {:ok, :inserted}
        _ -> {:error, :insert_failed}
      end
    end
  end

  def delete_timer_tag(timer_id, tag_id) do
    # Execute the delete operation on the "timer_tags" table
    case Repo.delete_all(
           from(tt in "timer_tags",
             where: tt.timer_id == ^timer_id and tt.tag_id == ^tag_id
           )
         ) do
      # No records were deleted
      {0, _} -> {:error, :not_found}
      # One record was deleted
      {1, _} -> {:ok, :deleted}
      # For any unexpected results
      _ -> {:error, :unexpected_result}
    end
  end

  @spec create_or_find_tag(attrs :: %{name: String.t()}) :: Tag.t()
  def create_or_find_tag(%{name: "" <> name} = attrs) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, tag} ->
        # Fetch all tags and regenerate the CSS
        tags = list_tags()
        DynamicCSS.generate_tag_styles(tags)
        tag

      {:error, changeset} ->
        {:error, changeset}

      _ ->
        Repo.get_by(Tag, name: name)
    end
  end

  def create_or_find_tag(_), do: nil

  @doc """
  Gets a single timer tag record.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_timer_tag!(123)
      %TimerTag{}

      iex> get_timer_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_timer_tag!(id), do: Repo.get_by!(TimerTags, id: id)

  @doc """
  """
  def delete_tag_from_timer(timer, tag) when is_struct(timer, Timer) and is_struct(tag, Tag) do
    Repo.get_by(TimerTags, timer_id: timer.id, tag_id: tag.id)
    |> case do
      %TimerTags{} = timer_tags -> Repo.delete(timer_tags)
      nil -> {:ok, %TimerTags{}}
    end
  end

  def delete_tag_from_timer(timer, tag) when is_struct(timer, Timer) and is_bitstring(tag) do
    Repo.get_by(TimerTags, timer_id: timer.id, tag_id: tag)
    |> case do
      %TimerTags{} = timer_tags -> Repo.delete(timer_tags)
      nil -> {:ok, %TimerTags{}}
    end
  end

  def delete_tag_from_timer(timer, tag) when is_bitstring(timer) and is_bitstring(tag) do
    Repo.get_by(TimerTags, timer_id: timer, tag_id: tag)
    |> case do
      %TimerTags{} = timer_tags -> Repo.delete(timer_tags)
      nil -> {:ok, %TimerTags{}}
    end
  end

  @doc """
  """
  def delete_timer_tag(%TimerTags{} = timer_tag) do
    Repo.delete(timer_tag)
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

  alias Klepsidra.Categorisation.ProjectTag

  @doc """
  Returns the list of project_tags.

  ## Examples

      iex> list_project_tags()
      [%ProjectTag{}, ...]

  """
  def list_project_tags do
    ProjectTag |> order_by(asc: fragment("name COLLATE NOCASE")) |> Repo.all()
  end

  @doc """
  Gets a single project_tag.

  Raises `Ecto.NoResultsError` if the Project tag does not exist.

  ## Examples

      iex> get_project_tag!(123)
      %ProjectTag{}

      iex> get_project_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project_tag!(id), do: Repo.get!(ProjectTag, id)

  @doc """
  Creates a project_tag.

  ## Examples

      iex> create_project_tag(%{field: value})
      {:ok, %ProjectTag{}}

      iex> create_project_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project_tag(attrs \\ %{}) do
    %ProjectTag{}
    |> ProjectTag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project_tag.

  ## Examples

      iex> update_project_tag(project_tag, %{field: new_value})
      {:ok, %ProjectTag{}}

      iex> update_project_tag(project_tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project_tag(%ProjectTag{} = project_tag, attrs) do
    project_tag
    |> ProjectTag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a project_tag.

  ## Examples

      iex> delete_project_tag(project_tag)
      {:ok, %ProjectTag{}}

      iex> delete_project_tag(project_tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project_tag(%ProjectTag{} = project_tag) do
    Repo.delete(project_tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project_tag changes.

  ## Examples

      iex> change_project_tag(project_tag)
      %Ecto.Changeset{data: %ProjectTag{}}

  """
  def change_project_tag(%ProjectTag{} = project_tag, attrs \\ %{}) do
    ProjectTag.changeset(project_tag, attrs)
  end
end
