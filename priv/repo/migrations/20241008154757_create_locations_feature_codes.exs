defmodule Klepsidra.Repo.Migrations.CreateFeatureCodes do
  use Ecto.Migration

  def change do
    create table(:locations_feature_codes,
             primary_key: false,
             comment:
               "GeoNames feature classes and codes with description, notes and an ordering field, for improved sorting support"
           ) do
      add(:feature_class, :string,
        primary_key: true,
        null: false,
        comment: "GeoNames composite primary key: feature class"
      )

      add(
        :feature_code,
        references(:locations_feature_classes,
          column: :feature_class,
          type: :binary_id,
          on_delete: :nothing,
          on_update: :nothing
        ),
        primary_key: true,
        null: false,
        comment: "GeoNames composite primary key: feature code"
      )

      add(:description, :string, comment: "GeoNames feature code description")
      add(:note, :string, comment: "GeoNames feature code notes and comments")

      add(:order, :integer,
        null: false,
        default: 0,
        comment: "An integer-based ordering field for an improved sorting of features"
      )

      timestamps()
    end

    create(
      unique_index(:locations_feature_codes, [:feature_class, :feature_code],
        comment: "Unique index on GeoNames' composite primary key, `class.code`"
      )
    )

    create(
      index(:locations_feature_codes, [:feature_class, :feature_code, :order],
        comment: "Composite index on `feature_class`, `feature_code` and `order` fields"
      )
    )

    create(
      index(:locations_feature_codes, [:order, :feature_class, :feature_code],
        comment: "Composite index on `order`, `feature_class` and `feature_code` fields"
      )
    )
  end
end
