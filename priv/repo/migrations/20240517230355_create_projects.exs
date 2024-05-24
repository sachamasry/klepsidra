defmodule Klepsidra.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string, null: false
      add :description, :string
      add :active, :boolean, default: true, null: false
      add :business_partner_id, references(:business_partners, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:projects, [:name])
  end
end
