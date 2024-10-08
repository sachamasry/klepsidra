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
  Creates a tag.

  ## Examples

      iex> create_tag(%{field: value})
      {:ok, %Tag{}}

      iex> create_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
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
  """
  def tag_timer(timer, %{tag: tag_attrs} = attrs) do
    tag = create_or_find_tag(tag_attrs)

    timer
    |> Ecto.build_assoc(:timer_tags)
    |> TimerTags.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:tag, tag)
    |> Repo.insert()
  end

  defp create_or_find_tag(%{name: "" <> name} = attrs) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, tag} -> tag
      _ -> Repo.get_by(Tag, name: name)
    end
  end

  defp create_or_find_tag(_), do: nil

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
  def delete_tag_from_timer(timer, tag) do
    Repo.get_by(TimerTags, timer_id: timer.id, tag_id: tag.id)
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
