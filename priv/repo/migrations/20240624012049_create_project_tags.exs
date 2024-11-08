defmodule Klepsidra.Repo.Migrations.CreateProjectTags do
  use Ecto.Migration

  def change do
    create table(:project_tags,
             primary_key: false,
             comment:
               "Project tags table, helping categorise projects with tags in a many-to-many relationship"
           ) do
      add(
        :project_id,
        references(:projects, on_delete: :delete_all, on_update: :update_all, type: :uuid),
        null: false,
        comment: "Foreign key referencing projects"
      )

      add(:tag_id, references(:tags, on_delete: :delete_all, on_update: :update_all, type: :uuid),
        null: false,
        comment: "Foreign key referencing tags"
      )

      timestamps()
    end

    create(
      unique_index(:project_tags, [:project_id, :tag_id],
        comment: "Composite unique index of `tag_id` and `project_id` fields"
      )
    )
  end
end
