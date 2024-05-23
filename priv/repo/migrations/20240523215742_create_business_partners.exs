defmodule Klepsidra.Repo.Migrations.CreateBusinessPartners do
  use Ecto.Migration

  def change do
    create table(:business_partners) do
      add :name, :string
      add :description, :string
      add :customer, :boolean, default: false, null: false
      add :supplier, :boolean, default: false, null: false
      add :active, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:business_partners, [:name])
  end
end
