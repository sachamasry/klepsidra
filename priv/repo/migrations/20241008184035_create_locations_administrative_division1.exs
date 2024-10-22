defmodule Klepsidra.Repo.Migrations.CreateLocationsAdministrativeDivision1 do
  use Ecto.Migration

  def change do
    create table(:locations_administrative_division1,
             primary_key: false,
             comment: "GeoNames administrative division 1 information table"
           ) do
      add(:country_code, :string,
        primary_key: true,
        null: false,
        comment: "Composite unique primary key: country_code.admin_division_code, country_code"
      )

      add(:administrative_division_code, :string,
        primary_key: true,
        null: false,
        comment:
          "Composite unique primary key: country_code.admin_division_code, administrative_division_code"
      )

      add(:administrative_division_name, :string,
        null: false,
        default: "",
        comment: "Administrative division name"
      )

      add(:administrative_division_name_ascii, :string,
        null: false,
        default: "",
        comment: "Administrative division name in ASCII characters only"
      )

      add(:geoname_id, :integer,
        null: false,
        comment: "GeoNames unique ID"
      )

      timestamps()
    end

    create(
      unique_index(
        :locations_administrative_division1,
        [:country_code, :administrative_division_code],
        comment:
          "Unique index on GeoNames' composite primary key, `country_code.admin_division_code`"
      )
    )

    create(
      index(:locations_administrative_division1, [:administrative_division_name],
        comment: "Index on administrative division name"
      )
    )

    create(
      index(:locations_administrative_division1, [:administrative_division_name_ascii],
        comment: "Index on administrative division ASCII character name"
      )
    )

    create(
      index(:locations_administrative_division1, [:geoname_id], comment: "Index on geonames_id")
    )
  end
end
