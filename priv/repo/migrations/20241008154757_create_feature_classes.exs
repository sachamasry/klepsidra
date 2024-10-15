defmodule Klepsidra.Repo.Migrations.CreateFeatureClasses do
  use Ecto.Migration

  def change do
    create table(:locations_feature_classes,
             primary_key: false,
             comment:
               "GeoNames feature codes and classes, with description, notes and an ordering field, for improved sorting support"
           ) do
      add(:feature_code, :string,
        null: false,
        comment: "GeoNames feature code"
      )

      add(:feature_class, :string,
        primary_key: true,
        null: false,
        comment: "GeoNames primary key: feature class"
      )

      add(:description, :string, comment: "GeoNames feature class description")
      add(:note, :string, comment: "GeoNames feature class notes and comments")

      add(:order, :integer,
        null: false,
        default: 0,
        comment: "An integer-based ordering field for an improved sorting of features"
      )

      timestamps()
    end

    create(
      unique_index(:locations_feature_classes, [:feature_code, :feature_class],
        comment: "Unique index on GeoNames' primary key, `code.class``"
      )
    )

    create(
      index(:locations_feature_classes, [:feature_code, :feature_class, :order],
        comment: "Composite index on `feature_code`, `feature_class` and `order` fields"
      )
    )

    create(
      index(:locations_feature_classes, [:order, :feature_code, :feature_class],
        comment: "Composite index on `order`, `feature_code` and `feature_class` fields"
      )
    )
  end
end
