defmodule Klepsidra.Repo.Migrations.CreateTimerTags do
  use Ecto.Migration

  def change do
    create table(:timer_tags) do
      add :tag_id, references(:tags, on_delete: :delete_all, on_replace: :delete)
      add :timer_id, references(:timers, on_delete: :delete_all, on_replace: :delete)

      timestamps()
    end

    create index(:timer_tags, [:tag_id])
    create index(:timer_tags, [:timer_id])
    create unique_index(:timer_tags, [:tag_id, :timer_id])
  end
end
