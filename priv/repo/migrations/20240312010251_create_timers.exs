defmodule Klepsidra.Repo.Migrations.CreateTimers do
  use Ecto.Migration

  def change do
    create table(:timers) do
      add :start_stamp, :string
      add :end_stamp, :string
      add :duration, :integer
      add :duration_time_unit, :string
      add :reported_duration, :integer
      add :reported_duration_time_unit, :string
      add :description, :string
      add :tag_id, references(:tags, on_delete: :nothing)

      timestamps()
    end
  end
end
