defmodule Klepsidra.Repo.Migrations.CreateProjectNotes do
  use Ecto.Migration

  def change do
    create table(:project_notes,
             comment: "Table to store project annotations and running comments"
           ) do
      add :note, :string, comment: "Note or commentary on the project"

      add :user_id, :integer,
        comment: "Unique identifier of the system user annotating the project"

      add :project_id, references(:projects, on_delete: :nothing),
        comment: "Foreign key referencing the project"

      timestamps()
    end

    create index(:project_notes, [:project_id],
             comment: "Index with the `project_id` as the main indexed key"
           )
  end
end
