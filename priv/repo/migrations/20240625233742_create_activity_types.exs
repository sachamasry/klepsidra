defmodule Klepsidra.Repo.Migrations.CreateActivityTypes do
  use Ecto.Migration

  def change do
    create table(:activity_types) do
      add :activity_type, :string
      add :billing_rate, :decimal
      add :active, :boolean, default: true, null: false

      timestamps()
    end
  end
end
