defmodule Klepsidra.KnowledgeManagement.NoteSearch do
  @moduledoc """
  Defines the `NoteSearch` schema needed to index user notes for full-text
  search.

  This entity will take in the string fields of the `Notes` entity:

  * title
  * content
  * summary
  * tags (concatenated string list of tag names, for additional discoverability)

  creating a copy of the data for its own purposes, generating
  _trigram_ idexes on all the above fields, providing substring
  searches.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true, source: :rowid}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          title: String.t(),
          content: String.t(),
          summary: String.t(),
          tags: String.t(),
          rank: float()
        }
  schema "knowledge_management_notes_search" do
    field :title, :string
    field :content, :string
    field :summary, :string
    field :tags, :string
    field :rank, :float, virtual: true
  end

  @doc false
  def changeset(note_search, attrs) do
    note_search
    |> cast(attrs, [:id, :title, :content, :summary])
    |> validate_required([:id, :title, :content])
  end
end
