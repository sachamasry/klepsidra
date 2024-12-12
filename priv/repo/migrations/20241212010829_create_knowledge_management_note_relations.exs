defmodule Klepsidra.Repo.Migrations.CreateKnowledgeManagementNoteRelations do
  use Ecto.Migration

  def change do
    create table(:knowledge_management_note_relations,
             primary_key: false,
             comment:
               "Record of relations (edges) between note entities (nodes), with a specified relationship_type, as well as flexibel, JSON-encoded relationship properties"
           ) do
      add :source_note_id,
          references(:knowledge_management_notes,
            on_delete: :nothing,
            on_update: :nothing,
            type: :uuid
          ),
          primary_key: true,
          null: false,
          comment: "References knowledge management notes, note to link 'from'"

      add :target_note_id,
          references(:knowledge_management_notes,
            on_delete: :nothing,
            on_update: :nothing,
            type: :uuid
          ),
          primary_key: true,
          null: false,
          comment: "References knowledge management notes, note to link 'to'"

      add(
        :relationship_type_id,
        references(:knowledge_management_relationship_types,
          on_delete: :nothing,
          on_update: :nothing,
          type: :uuid
        ),
        primary_key: true,
        null: false,
        comment:
          "References knowledge management relationship types, specifies the nature of the relationship between these two note records"
      )

      add :properties, :map, null: true

      timestamps()
    end

    create(
      index(:knowledge_management_note_relations, [:source_note_id],
        comment: "Index of `source_note_id` field"
      )
    )

    create(
      index(:knowledge_management_note_relations, [:target_note_id],
        comment: "Index of `source_note_id` field"
      )
    )

    create(
      index(:knowledge_management_note_relations, [:source_note_id, :target_note_id],
        comment: "Composite index of `source_note_id` and `target_note_id` fields"
      )
    )

    create(
      index(:knowledge_management_note_relations, [:target_note_id, :source_note_id],
        comment: "Composite index of `target_note_id` and `source_note_id`  fields"
      )
    )
  end
end
