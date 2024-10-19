defmodule Klepsidra.Repo.Migrations.CreateLocationsContinents do
  use Ecto.Migration

  def change do
    create table(:locations_continents,
             primary_key: false,
             comment:
               "World continent list, with continent codes and names, from GeoNames project"
           ) do
      add(:continent_code, :string,
        primary_key: true,
        null: false,
        comment: "Two character unique continent code"
      )

      add(:continent_name, :string,
        null: false,
        comment: "Continent name"
      )

      add(:geoname_id, :integer,
        null: false,
        comment: "Unique GeoNames project identifier"
      )

      timestamps()
    end

    create(
      unique_index(:locations_continents, [:continent_code],
        comment: "Unique index on two-character continent code primary key"
      )
    )

    create(
      unique_index(:locations_continents, [:continent_name],
        comment: "Unique index on continent name field"
      )
    )
  end
end
