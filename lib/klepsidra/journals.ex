defmodule Klepsidra.Journals do
  @moduledoc """
  The Journals context.
  """

  import Ecto.Query, warn: false
  alias Klepsidra.Repo

  alias Klepsidra.Journals.Category

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories do
    Repo.all(Category)
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id), do: Repo.get!(Category, id)

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  alias Klepsidra.Journals.JournalEntry

  @doc """
  Returns the list of journal_entries.

  ## Examples

      iex> list_journal_entries()
      [%JournalEntry{}, ...]

  """
  def list_journal_entries do
    Repo.all(JournalEntry)
  end

  @doc """
  Gets a single journal_entry.

  Raises `Ecto.NoResultsError` if the Journal entry does not exist.

  ## Examples

      iex> get_journal_entry!(123)
      %JournalEntry{}

      iex> get_journal_entry!(456)
      ** (Ecto.NoResultsError)

  """
  def get_journal_entry!(id), do: Repo.get!(JournalEntry, id)

  @doc """
  Creates a journal_entry.

  ## Examples

      iex> create_journal_entry(%{field: value})
      {:ok, %JournalEntry{}}

      iex> create_journal_entry(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_journal_entry(attrs \\ %{}) do
    %JournalEntry{}
    |> JournalEntry.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a journal_entry.

  ## Examples

      iex> update_journal_entry(journal_entry, %{field: new_value})
      {:ok, %JournalEntry{}}

      iex> update_journal_entry(journal_entry, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_journal_entry(%JournalEntry{} = journal_entry, attrs) do
    journal_entry
    |> JournalEntry.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a journal_entry.

  ## Examples

      iex> delete_journal_entry(journal_entry)
      {:ok, %JournalEntry{}}

      iex> delete_journal_entry(journal_entry)
      {:error, %Ecto.Changeset{}}

  """
  def delete_journal_entry(%JournalEntry{} = journal_entry) do
    Repo.delete(journal_entry)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking journal_entry changes.

  ## Examples

      iex> change_journal_entry(journal_entry)
      %Ecto.Changeset{data: %JournalEntry{}}

  """
  def change_journal_entry(%JournalEntry{} = journal_entry, attrs \\ %{}) do
    JournalEntry.changeset(journal_entry, attrs)
  end
end
