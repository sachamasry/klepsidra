defmodule Klepsidra.Repo.Migrations.CreateNotes do
  use Ecto.Migration

  def change do
    create table(:notes) do
      add :note, :string
      add :user_id, :integer
      add :timer_id, references(:timers, on_delete: :nothing)

      timestamps()
    end

    create index(:notes, [:timer_id])
  end
end
