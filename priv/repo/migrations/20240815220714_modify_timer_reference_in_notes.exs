defmodule Klepsidra.Repo.Migrations.AddNotesBelongToTimers do
  use Ecto.Migration

  def change do
    # First, drop the old foreign key constraint
    drop constraint(:timer_notes, "timer_notes_timer_id_fkey")

    # Then, add the new foreign key constraint with `on_delete: :delete_all`
    alter table(:timer_notes) do
      modify :timer_id, references(:timers, on_delete: :delete_all, type: :uuid), null: false
    end
  end
end
