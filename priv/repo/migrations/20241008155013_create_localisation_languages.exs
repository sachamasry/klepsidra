defmodule Klepsidra.Repo.Migrations.CreateLocalisationLanguages do
  use Ecto.Migration

  def change do
    create table(:localisation_languages,
             primary_key: false,
             comment: "World language ISO 639 language codes list, from the GeoNames project"
           ) do
      add(:"iso_639-3_language_code", :string,
        primary_key: true,
        null: false,
        comment:
          "ISO 639 Part 3: Alpha-3 code for comprehensive coverage of languages, and the table's primary key for as long as ISO 639-3 is the dominant language standard"
      )

      add(:"iso_639-2_language_code", :string,
        null: true,
        default: "",
        comment: "ISO 639 Part 2: Alpha-3 code"
      )

      add(:"iso_639-1_language_code", :string,
        null: true,
        default: "",
        comment: "ISO 639 Part 1: Alpha-2 code"
      )

      add(:language_name, :string,
        null: false,
        comment: "Language name"
      )

      timestamps()
    end

    create(
      unique_index(:localisation_languages, [:"iso_639-3_language_code"],
        comment: "Unique index on ISO 639-3 language code"
      )
    )

    create(
      index(:localisation_languages, [:"iso_639-3_language_code", :language_name],
        comment: "Index of ISO 639-3 language codes and names"
      )
    )

    create(
      index(:localisation_languages, [:"iso_639-2_language_code"],
        comment: "Index of ISO 639-2 language code"
      )
    )

    create(
      index(:localisation_languages, [:"iso_639-2_language_code", :language_name],
        comment: "Index of ISO 639-2 language codes and names"
      )
    )

    create(
      index(:localisation_languages, [:"iso_639-1_language_code"],
        comment: "Index of ISO 639-1 language code"
      )
    )

    create(
      index(:localisation_languages, [:"iso_639-1_language_code", :language_name],
        comment: "Index of ISO 639-1 language codes and names"
      )
    )

    create(index(:localisation_languages, [:language_name], comment: "Index of language names"))
  end
end
