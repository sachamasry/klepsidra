defmodule Klepsidra.Repo.Migrations.CreateProjectTags do
  use Ecto.Migration

  def change do
    create table(:project_tags) do
      add :tag_id, references(:tags, on_delete: :delete_all, on_replace: :delete)
      add :project_id, references(:projects, on_delete: :delete_all, on_replace: :delete)

      timestamps()
    end

    create index(:project_tags, [:tag_id])
    create index(:project_tags, [:project_id])
    create unique_index(:project_tags, [:tag_id, :project_id])
  end
end
