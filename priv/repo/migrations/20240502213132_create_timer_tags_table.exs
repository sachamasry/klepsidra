defmodule Klepsidra.Repo.Migrations.CreateTimerTags do
  use Ecto.Migration

  def change do
    create table(:timer_tags) do
      add :tag_id, references(:tags, on_delete: :delete_all, on_replace: :delete)
      add :timer_id, references(:timers, on_delete: :delete_all, on_replace: :delete)
      add :position, :integer, null: false

      timestamps()
    end
  end
end
