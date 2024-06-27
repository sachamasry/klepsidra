defmodule Klepsidra.Repo.Migrations.CreateProjectTags do
  use Ecto.Migration

  def change do
    create table(:project_tags,
             primary_key: false,
             comment:
               "Project tags table, helping categorise projects with tags in a many-to-many relationship"
           ) do
      add :id, :uuid,
        primary_key: true,
        null: false,
        comment: "UUID-based project tags primary key"

      add :tag_id, references(:tags, on_delete: :delete_all, on_replace: :delete, type: :uuid),
        comment: "Foreign key referencing tags"

      add :project_id,
          references(:projects, on_delete: :delete_all, on_replace: :delete, type: :uuid),
          comment: "Foreign key referencing projects"

      timestamps()
    end

    create index(:project_tags, [:tag_id], comment: "Index with the `tag_id` as an indexed key")

    create index(:project_tags, [:project_id],
             comment: "Index with the project `project_id` as an indexed key"
           )

    create unique_index(:project_tags, [:tag_id, :project_id],
             comment:
               "Index with the project `project_id` and `tag_id` as a composite indexed key"
           )
  end
end
