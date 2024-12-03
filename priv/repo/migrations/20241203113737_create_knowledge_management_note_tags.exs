defmodule Klepsidra.Repo.Migrations.CreateKnowledgeManagementNoteTags do
  use Ecto.Migration

  def change do
    create table(:knowledge_management_note_tags,
             primary_key: false,
             comment:
               "Knoledge Management note tags table, categorising notes with tags in a many-to-many relationship"
           ) do
      add :note_id,
          references(:knowledge_management_notes,
            on_delete: :nothing,
            on_update: :nothing,
            type: :uuid
          ),
          primary_key: true,
          null: false,
          comment: "Foreign key referencing knowledge management notes"

      add :tag_id, references(:tags, on_delete: :nothing, on_update: :nothing, type: :uuid),
        primary_key: true,
        null: false,
        comment: "Foreign key referencing tags"

      timestamps()
    end

    create(
      unique_index(:knowledge_management_note_tags, [:note_id, :tag_id],
        comment: "Composite unique index of `note_id` and `tag_id` fields"
      )
    )
  end
end
