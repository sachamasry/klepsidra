defmodule Klepsidra.Repo.Migrations.CreateCountries do
  use Ecto.Migration

  def change do
    create table(:locations_countries,
             primary_key: false,
             comment: "GeoNames country information table"
           ) do
      add(:iso, :string,
        primary_key: true,
        null: false,
        comment: "Unique primary key, ISO-3166 2-letter country code, 2 characters"
      )

      add(:iso_3, :string,
        null: false,
        comment: "ISO 3 country code, 3 characters"
      )

      add(:iso_numeric, :integer,
        null: false,
        comment: "ISO numeric identifier"
      )

      add(:fips, :string,
        null: true,
        default: "",
        comment: "FIPS code"
      )

      add(:country_name, :string,
        null: false,
        comment: "Full country name"
      )

      add(:capital, :string,
        null: true,
        default: "",
        comment: "Country's capital city"
      )

      add(:area, :float,
        null: false,
        comment: "Country area, in square kilometres, floating point for small countries"
      )

      add(:population, :integer,
        null: false,
        comment: "Country population"
      )

      add(:continent, :string,
        null: false,
        default: "",
        comment: "Continent the country belongs to"
      )

      add(:tld, :string,
        null: true,
        default: "",
        comment: "Country's top-level domain"
      )

      add(:currency_code, :string,
        null: true,
        default: "",
        comment: "3 character currency code, for the official currency"
      )

      add(:currency_name, :string,
        null: true,
        default: "",
        comment: "Name of country's official currency"
      )

      add(:phone, :string,
        null: true,
        default: "",
        comment: "Telephone dialing code"
      )

      add(:postal_code_format, :string,
        null: true,
        default: "",
        comment: "Postal code format, in number of characters"
      )

      add(:postal_code_regex, :string,
        null: true,
        default: "",
        comment: "Postal code regex, for accurate automated validation"
      )

      add(:languages, :string,
        null: true,
        default: "",
        comment: "List of official languages"
      )

      add(:geoname_id, :integer,
        null: false,
        comment: "GeoNames' unique identifier"
      )

      add(:neighbours, :string,
        null: true,
        default: "",
        comment: "List of neighbouring countries"
      )

      add(:equivalent_fips_code, :string,
        null: true,
        default: "",
        comment: "Equivalent FIPS code"
      )

      timestamps()
    end

    create(
      unique_index(:locations_countries, [:iso],
        comment: "Primary key, unique two-character country identification code"
      )
    )

    create(
      unique_index(:locations_countries, [:iso_3],
        comment: "Unique three-character country identification code"
      )
    )

    create(
      unique_index(:locations_countries, [:iso_numeric],
        comment: "Unique numeric ISO country identification code"
      )
    )

    create(
      unique_index(:locations_countries, [:geoname_id],
        comment: "Unique GeoNames' identifier (integer)"
      )
    )

    create(index(:locations_countries, [:country_name], comment: "Index on country name"))

    create(
      index(:locations_countries, [:country_name, :population, :area],
        comment: "Index on country name, population size, surface area"
      )
    )

    create(
      index(:locations_countries, [:country_name, :area, :population],
        comment: "Index on country name, surface area, population size"
      )
    )

    create(index(:locations_countries, [:continent], comment: "Index on continent"))

    create(index(:locations_countries, [:tld], comment: "Index on top-level domain"))

    create(index(:locations_countries, [:currency_code], comment: "Index on currency code"))
  end
end
