defmodule Klepsidra.ReporterRepo.Migrations.CreateReportJobs do
  use Ecto.Migration

  def change do
    create table(:report_jobs) do
      add :status, :string, default: "pending"
      add :report_fingerprint, :string
      add :parameters, :text
      add :result_path, :string

      timestamps()
    end
  end
end
