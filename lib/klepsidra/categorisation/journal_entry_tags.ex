defmodule Klepsidra.Categorisation.JournalEntryTags do
  @moduledoc """
  Defines a schema for the `JournalEntryTags` entity, used to create a many-to-many
  relationship between journal entries and tags.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Klepsidra.Journals.JournalEntry
  alias Klepsidra.Categorisation.Tag

  @primary_key false
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          journal_entry_id: Ecto.UUID.t(),
          tag_id: Ecto.UUID.t()
        }
  schema "journal_entry_tags" do
    belongs_to(:journal_entry, JournalEntry, primary_key: true, type: Ecto.UUID)
    belongs_to(:tag, Tag, primary_key: true, type: Ecto.UUID)

    timestamps()
  end

  @doc false
  def changeset(journal_entry_tags, _attrs) do
    journal_entry_tags
    |> unique_constraint([:journal_entry, :tag],
      name: "journal_entry_tags_journal_entry_id_tag_id_index",
      message: "This tag has already been added to the journal entry"
    )
    |> cast_assoc(:tag)
  end
end
