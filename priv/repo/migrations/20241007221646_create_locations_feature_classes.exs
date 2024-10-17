defmodule Klepsidra.Repo.Migrations.CreateLocationsFeatureClasses do
  use Ecto.Migration

  def change do
    create table(:locations_feature_classes,
             primary_key: false,
             comment:
               "All feature classes used in GeoNames tables for categorisation of locations. This data comes from the [GeoNames project](https://geonames.org/)"
           ) do
      add(:feature_class, :string,
        primary_key: true,
        null: false,
        comment: "One-character feature class for location categorisation"
      )

      add(:description, :string,
        null: true,
        default: "",
        comment: "Describes the uses for this class"
      )

      timestamps()
    end

    create(
      unique_index(:locations_feature_classes, [:feature_class],
        comment: "Unique index on primary key, `feature_class``"
      )
    )
  end
end
