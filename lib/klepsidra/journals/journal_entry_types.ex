defmodule Klepsidra.Journals.JournalEntryTypes do
  @moduledoc """
  Defines the `JournalEntryTypes` schema and functions needed to categorise the
  type of journal entries recorded.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          name: String.t(),
          description: String.t(),
          active: boolean()
        }
  schema "journal_entry_types" do
    field :name, :string
    field :description, :string
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(journal_entry_types, attrs) do
    journal_entry_types
    |> cast(attrs, [:name, :description, :active])
    |> validate_required(:name, message: "Enter a journal entry type")
    |> unique_constraint(:name,
      message: "A journal entry type with this name already exists"
    )
  end

  @doc """
  Used across live components to populate select options with journal entry types.
  """
  @spec populate_entry_types_list() :: [Klepsidra.Journals.JournalEntryTypes.t(), ...]
  def populate_entry_types_list() do
    [
      {"", ""}
      | Klepsidra.Journals.list_journal_entry_types()
        |> Enum.map(fn entry_type -> {entry_type.name, entry_type.id} end)
    ]
  end
end
