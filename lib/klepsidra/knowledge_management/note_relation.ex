defmodule Klepsidra.KnowledgeManagement.NoteRelation do
  @moduledoc """
  Defines the `NoteRelation` schema to create relationships between a
  pair of notes, along with their relationship type.

  Notes are primary units of thought and knowledge, and their interlinking
  forms a knowledge base.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Klepsidra.KnowledgeManagement.Note
  alias Klepsidra.KnowledgeManagement.RelationshipType

  @primary_key false
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          source_note_id: Ecto.UUID.t(),
          target_note_id: Ecto.UUID.t(),
          relationship_type_id: Ecto.UUID.t(),
          properties: map()
        }
  schema "knowledge_management_note_relations" do
    belongs_to(:source_note, Note, primary_key: true, type: Ecto.UUID)
    belongs_to(:target_note, Note, primary_key: true, type: Ecto.UUID)
    belongs_to(:relationship_type, RelationshipType, primary_key: true, type: Ecto.UUID)
    field :properties, :map

    timestamps()
  end

  @doc false
  def changeset(note_relation, attrs) do
    note_relation
    |> cast(attrs, [:source_note_id, :target_note_id, :relationship_type_id, :properties])
    |> unique_constraint([:source_note, :target_note, :relationship_type],
      name:
        "knowledge_management_note_relations_source_note_id_target_note_id_relationship_type_id_index",
      message: "These notes have already been related with that relationship type"
    )
    |> validate_required([:source_note_id, :target_note_id, :relationship_type_id])
  end
end
