defmodule Klepsidra.KnowledgeManagement.NoteTags do
  @moduledoc """
  Defines a schema for the `NoteTags` entity, used to create a many-to-many
  relationship between knowledge management notes and tags.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Klepsidra.KnowledgeManagement.Note

  @primary_key false
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          note_id: Ecto.UUID.t(),
          tag_id: Ecto.UUID.t()
        }
  schema "knowledge_management_note_tags" do
    belongs_to(:note, Note, primary_key: true, type: Ecto.UUID)
    belongs_to(:tag, Tag, primary_key: true, type: Ecto.UUID)

    timestamps()
  end

  @doc false
  def changeset(knowledge_management_note_tags, attrs) do
    knowledge_management_note_tags
    |> unique_constraint([:note, :tag],
      name: "knowledge_management_note_tags_note_id_tag_id_inde",
      message: "This tag has already been added to the note"
    )
    |> cast(attrs, [:note_id, :tag_id])
    |> validate_required([:note_id, :tag_id])
  end
end
