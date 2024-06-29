defmodule Klepsidra.Repo.Migrations.CreateProjectNotes do
  use Ecto.Migration

  def change do
    create table(:project_notes,
             primary_key: false,
             comment: "Table to store project annotations and running comments"
           ) do
      add :id, :uuid,
        primary_key: true,
        null: false,
        comment: "UUID-based project notes primary key"

      add :note, :text, comment: "Note or commentary on the project"

      add :project_id, references(:projects, on_delete: :nothing, type: :uuid),
        comment: "Foreign key referencing the project"

      timestamps()
    end

    create index(:project_notes, [:project_id],
             comment: "Index with the `project_id` as the main indexed key"
           )

    create index(:project_notes, [:inserted_at, :updated_at],
             comment:
               "Composite Index of `inserted_at` and `updated_at` fields, for chronological ordering"
           )
  end
end
