defmodule Klepsidra.Repo.Migrations.CreateFeatureCodes do
  use Ecto.Migration

  def change do
    create table(:locations_feature_codes,
             primary_key: false,
             comment:
               "GeoNames feature classes and codes with description, notes and an ordering field, for improved sorting support"
           ) do
      add(
        :feature_code,
        :string,
        primary_key: true,
        null: false,
        comment: "GeoNames feature code primary key"
      )

      add(
        :feature_class,
        references(:locations_feature_classes,
          column: :feature_class,
          type: :binary_id,
          on_delete: :nothing,
          on_update: :nothing
        ),
        null: false,
        comment: "GeoNames feature class foreign key"
      )

      add(:order, :integer,
        null: false,
        default: 0,
        comment: "An integer-based ordering field for an improved sorting of features"
      )

      add(:description, :string,
        null: true,
        default: "",
        comment: "GeoNames feature code description"
      )

      add(:note, :string,
        null: true,
        default: "",
        comment: "GeoNames feature code notes and comments"
      )

      timestamps()
    end

    create(
      index(:locations_feature_codes, [:feature_code, :feature_class, :order],
        comment: "Composite index on `feature_code`, `feature_class` and `order` fields"
      )
    )

    create(
      index(:locations_feature_codes, [:feature_code, :order],
        comment: "Composite index on `feature_code` and `order` fields"
      )
    )

    create(
      index(:locations_feature_codes, [:order, :feature_code],
        comment: "Composite index on `order` and `feature_code` fields"
      )
    )
  end
end
