defmodule Klepsidra.Repo.Migrations.CreateNotes do
  use Ecto.Migration

  def change do
    create table(:timer_notes,
             primary_key: false,
             comment: "Table to store activity timer annotations and running comments"
           ) do
      add :id, :uuid,
        primary_key: true,
        null: false,
        comment: "UUID-based timer notes primary key"

      add :note, :text, comment: "Note or commentary on the activity timer"

      add :timer_id, references(:timers, on_delete: :nothing, type: :uuid),
        comment: "Foreign key referencing the activity timer"

      timestamps()
    end

    create index(:timer_notes, [:timer_id],
             comment: "Index with the `timer_id` as the main indexed key"
           )

    create index(:timer_notes, [:inserted_at, :updated_at],
             comment:
               "Composite Index of `inserted_at` and `updated_at` fields, for chronological ordering"
           )
  end
end
