defmodule Klepsidra.ReporterRepo.Migrations.CreateReportJobs do
  use Ecto.Migration

  def change do
    create table(:report_jobs) do
      add :state, :string, default: "pending"
      add :report_fingerprint, :string
      add :parameters, :text
      add :attempt, :integer, default: 0
      add :max_attempts, :integer, default: 3
      add :priority, :integer, default: 0
      add :result_path, :string

      timestamps()

      add :scheduled_at, :string
      add :attempted_at, :string
      add :attempted_by, :map, default: %{}
      add :cancelled_at, :string
      add :completed_at, :string
      add :discarded_at, :string
    end
  end
end
