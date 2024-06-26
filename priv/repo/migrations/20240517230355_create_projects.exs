defmodule Klepsidra.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string, null: false
      add :description, :string
      add :status, :string
      add :project_type, :string
      add :priority, :string
      add :business_partner_id, references(:business_partners, on_delete: :nothing)
      add :expected_start_date, :date
      add :expected_end_date, :date
      add :actual_start_date, :date
      add :actual_end_date, :date
      add :estimated_duration, :integer
      add :estimated_duration_time_unit, :string
      add :billable, :boolean, default: false, null: false
      add :estimated_total_billable_amount, :decimal
      add :active, :boolean, default: true, null: false

      timestamps()
    end

    create unique_index(:projects, [:name])
  end
end
