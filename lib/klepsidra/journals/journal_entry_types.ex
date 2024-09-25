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
          description: String.t()
        }
  schema "journal_entry_types" do
    field :name, :string
    field :description, :string

    timestamps()
  end

  @doc false
  def changeset(journal_entry_types, attrs) do
    journal_entry_types
    |> cast(attrs, [:name, :description])
    |> validate_required(:name, message: "Enter a journal entry type")
    |> unique_constraint(:name, message: "A journal entry type with that name already exists")
  end
end
