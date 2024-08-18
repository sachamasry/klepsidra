defmodule Klepsidra.Repo.Migrations.AddNotesBelongToTimers do
  use Ecto.Migration

  def up do
    # Rename the old table
    rename table(:timer_notes), to: table(:old_timer_notes)

    # Create new timer notes table with the correct foreign key constraint
    create table(:timer_notes,
             primary_key: false,
             comment: "Table to store activity timer annotations and running comments"
           ) do
      add :id, :uuid,
        primary_key: true,
        null: false,
        comment: "UUID-based timer notes primary key"

      add :note, :text, null: false, comment: "Note or commentary on the activity timer"

      add :timer_id, references(:timers, on_delete: :delete_all, type: :uuid),
        null: false,
        comment: "Foreign key referencing the activity timer"

      timestamps()
    end

    # Copy data from the old table to the new one
    execute "INSERT INTO timer_notes (id, note, timer_id, inserted_at, updated_at) SELECT id, note, timer_id, inserted_at, updated_at FROM old_timer_notes"

    # Drop the old table
    drop table(:old_timer_notes)
  end

  def down do
    # Recreate the old table if the migration is rolled back
    create table(:old_timer_notes,
             primary_key: false,
             comment: "Table to store activity timer annotations and running comments"
           ) do
      add :id, :uuid,
        primary_key: true,
        null: false,
        comment: "UUID-based timer notes primary key"

      add :note, :text, null: false, comment: "Note or commentary on the activity timer"

      add :timer_id, references(:timers, on_delete: :nothing, type: :uuid),
        null: false,
        comment: "Foreign key referencing the activity timer"

      timestamps()
    end

    # Copy data back from the new timer_notes table to the old_timer_notes table
    execute "INSERT INTO old_timer_notes (id, note, timer_id, inserted_at, updated_at) SELECT id, note, timer_id, inserted_at, updated_at FROM timer_notes"

    # Drop the new timer_notes table
    drop table(:timer_notes)

    # Rename the old_notes table back to notes
    rename table(:old_timer_notes), to: table(:timer_notes)
  end
end
