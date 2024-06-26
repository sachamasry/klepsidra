defmodule Klepsidra.Repo.Migrations.CreateBusinessPartners do
  use Ecto.Migration

  def change do
    create table(:business_partners) do
      add :name, :string
      add :description, :string
      add :default_currency, :string
      add :customer, :boolean, default: false, null: false
      add :supplier, :boolean, default: false, null: false
      add :frozen, :boolean, default: false, null: false
      add :active, :boolean, default: true, null: false

      timestamps()
    end

    create unique_index(:business_partners, [:name])
  end
end
