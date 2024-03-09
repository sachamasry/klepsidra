defmodule Klepsidra.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :tag, :string
      add :name, :string
      add :colour, :string
      add :description, :string

      timestamps()
    end
  end
end
