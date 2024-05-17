defmodule Klepsidra.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string, null: false
      add :description, :string
      add :active, :boolean, default: true, null: false

      timestamps()
    end

    create unique_index(:projects, [:name])
  end
end
