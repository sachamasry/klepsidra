defmodule Klepsidra.KnowledgeManagement.NoteSearch do
  @moduledoc """
  Defines the `NoteSearch` schema needed to index user notes for full-text
  search.

  This entity will take in the string fields of the `Notes` entity:

  * `title`
  * `content`
  * `summary`
  * `tags` (concatenated string list of tag names, for additional discoverability)

  as well as `note_id`, to be able to refer back to the correct
  notes record.

  This creates a copy of the data for its own purposes, generating
  _trigram_ idexes on all the above fields, providing substring
  searches.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true, source: :rowid}

  @type t :: %__MODULE__{
          id: integer(),
          note_id: Ecto.UUID.t(),
          title: String.t(),
          content: String.t(),
          summary: String.t(),
          tags: String.t(),
          rank: float()
        }
  schema "knowledge_management_notes_search" do
    field :note_id, :bitstring
    field :title, :string
    field :content, :string
    field :summary, :string
    field :tags, :string
    field :rank, :float, virtual: true
  end

  @doc false
  def changeset(note_search, attrs) do
    note_search
    |> cast(attrs, [:id, :note_id, :title, :content, :summary, :tags])
    |> validate_required([:id, :note_id, :title, :content])
  end
end
