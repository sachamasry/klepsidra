defmodule Klepsidra.Repo.Migrations.CreateLocationsAdministrativeDivision2 do
  use Ecto.Migration

  def change do
    create table(:locations_administrative_division2,
             primary_key: false,
             comment:
               "GeoNames administrative division 2 information table: subregions, councils, boroughs, etc."
           ) do
      add(:administrative_division2_code, :string,
        primary_key: true,
        null: false,
        comment:
          "Unique primary key consisting of `country_code.admin_division1_code.admin_division2_code` components"
      )

      add(
        :administrative_division1_code,
        references(:locations_administrative_division1,
          column: :administrative_division1_code,
          type: :binary_id,
          on_delete: :nothing,
          on_update: :nothing
        ),
        null: false,
        comment:
          "Foreign key referencing the parent administrative division 1 code the administrative division belongs to"
      )

      add(
        :country_code,
        references(:locations_countries,
          column: :iso,
          type: :binary_id,
          on_delete: :nothing,
          on_update: :nothing
        ),
        null: false,
        comment: "Foreign key referencing the country the administrative division belongs to"
      )

      add(:administrative_division_name, :string,
        null: false,
        default: "",
        comment: "Administrative division name"
      )

      add(:administrative_division_ascii_name, :string,
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
        :locations_administrative_division2,
        [:administrative_division2_code],
        comment:
          "Unique index on GeoNames' composite primary key, `country_code.admin_division1_code.admin_division2_code`"
      )
    )

    create(
      index(:locations_administrative_division2, [:administrative_division1_code],
        comment: "Index on administrative division 1 code"
      )
    )

    create(
      index(:locations_administrative_division2, [:country_code],
        comment: "Index on country code"
      )
    )

    create(
      index(:locations_administrative_division2, [:administrative_division_name],
        comment: "Index on administrative division name"
      )
    )

    create(
      index(:locations_administrative_division2, [:administrative_division_ascii_name],
        comment: "Index on administrative division ASCII character name"
      )
    )

    create(
      index(:locations_administrative_division2, [:geoname_id], comment: "Index on geoname_id")
    )
  end
end
