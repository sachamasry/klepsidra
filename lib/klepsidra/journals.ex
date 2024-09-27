defmodule Klepsidra.Journals do
  @moduledoc """
  The Journals context.
  """

  import Ecto.Query, warn: false
  alias Klepsidra.Repo

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
  Given a result of a `journal_entries` query, additionally preload the
  `entry_type` association.

  ## Examples

      iex> list_journal_entries() |> preload_journal_entry_type()
      [%JournalEntry{%Klepsidra.Journals.JournalEntryTypes{}}, ...]

  """
  @spec preload_journal_entry_type([Klepsidra.Journals.JournalEntry.t(), ...]) :: [
          Klepsidra.Journals.JournalEntry.t(),
          ...
        ]
  def preload_journal_entry_type(journal_entries) when is_list(journal_entries) do
    Repo.preload(journal_entries, :entry_type)
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

  alias Klepsidra.Journals.JournalEntryTypes

  @doc """
  Returns the list of journal_entry_types.

  ## Examples

      iex> list_journal_entry_types()
      [%JournalEntryTypes{}, ...]

  """
  def list_journal_entry_types do
    Repo.all(JournalEntryTypes)
  end

  @doc """
  Gets a single journal_entry_types.

  Raises `Ecto.NoResultsError` if the Journal entry types does not exist.

  ## Examples

      iex> get_journal_entry_types!(123)
      %JournalEntryTypes{}

      iex> get_journal_entry_types!(456)
      ** (Ecto.NoResultsError)

  """
  def get_journal_entry_types!(id), do: Repo.get!(JournalEntryTypes, id)

  @doc """
  Creates a journal_entry_types.

  ## Examples

      iex> create_journal_entry_types(%{field: value})
      {:ok, %JournalEntryTypes{}}

      iex> create_journal_entry_types(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_journal_entry_types(attrs \\ %{}) do
    %JournalEntryTypes{}
    |> JournalEntryTypes.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a journal_entry_types.

  ## Examples

      iex> update_journal_entry_types(journal_entry_types, %{field: new_value})
      {:ok, %JournalEntryTypes{}}

      iex> update_journal_entry_types(journal_entry_types, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_journal_entry_types(%JournalEntryTypes{} = journal_entry_types, attrs) do
    journal_entry_types
    |> JournalEntryTypes.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a journal_entry_types.

  ## Examples

      iex> delete_journal_entry_types(journal_entry_types)
      {:ok, %JournalEntryTypes{}}

      iex> delete_journal_entry_types(journal_entry_types)
      {:error, %Ecto.Changeset{}}

  """
  def delete_journal_entry_types(%JournalEntryTypes{} = journal_entry_types) do
    Repo.delete(journal_entry_types)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking journal_entry_types changes.

  ## Examples

      iex> change_journal_entry_types(journal_entry_types)
      %Ecto.Changeset{data: %JournalEntryTypes{}}

  """
  def change_journal_entry_types(%JournalEntryTypes{} = journal_entry_types, attrs \\ %{}) do
    JournalEntryTypes.changeset(journal_entry_types, attrs)
  end
end
