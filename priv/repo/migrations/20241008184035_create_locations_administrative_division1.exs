defmodule Klepsidra.Repo.Migrations.CreateLocationsAdministrativeDivisions1 do
  use Ecto.Migration

  def change do
    create table(:locations_administrative_divisions_1,
             primary_key: false,
             comment:
               "GeoNames administrative division 1 information table: states, provinces, etc."
           ) do
      add(:administrative_division_1_code, :string,
        primary_key: true,
        null: false,
        comment: "Unique primary key consisting of `country_code.admin_division_code` components"
      )

      add(
        :country_code,
        references(:locations_countries,
          column: :iso_country_code,
          type: :binary_id,
          on_delete: :nothing,
          on_update: :nothing
        ),
        null: false,
        comment: "Foreign key referencing the country the administrative division belongs to"
      )

      add(:administrative_division_1_name, :string,
        null: false,
        default: "",
        comment: "Administrative division name"
      )

      add(:administrative_division_1_ascii_name, :string,
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
        :locations_administrative_divisions_1,
        [:administrative_division_1_code],
        comment:
          "Unique index on GeoNames' composite primary key, `country_code.admin_division_code`"
      )
    )

    create(
      index(:locations_administrative_divisions_1, [:country_code],
        comment: "Index on country code"
      )
    )

    create(
      index(:locations_administrative_divisions_1, [:administrative_division_1_name],
        comment: "Index on administrative division name"
      )
    )

    create(
      index(:locations_administrative_divisions_1, [:administrative_division_1_ascii_name],
        comment: "Index on administrative division ASCII character name"
      )
    )

    create(
      index(:locations_administrative_divisions_1, [:geoname_id], comment: "Index on geonames_id")
    )
  end
end
