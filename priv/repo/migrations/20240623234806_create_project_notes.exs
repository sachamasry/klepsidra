defmodule Klepsidra.Repo.Migrations.CreateProjectNotes do
  use Ecto.Migration

  def change do
    create table(:project_notes) do
      add :note, :string
      add :user_id, :integer
      add :project_id, references(:projects, on_delete: :nothing)

      timestamps()
    end

    create index(:project_notes, [:project_id])
  end
end
