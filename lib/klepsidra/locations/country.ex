defmodule Klepsidra.Locations.Country do
  @moduledoc """
  Defines a schema for the `Country` entity, listing the countries of the world.

  This is not meant to be a user-editable entity, imported on a periodic basis
  from the [Geonames](https://geonames.org) project, specifically the `countryInfo.txt`
  file, all countries' information, with the file annotation headers stripped off
  and column headers converted to lowercase, underscore-separated names.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @type t :: %__MODULE__{
          iso: String.t(),
          iso_3: String.t(),
          iso_numeric: integer(),
          fips: String.t(),
          country_name: String.t(),
          capital: String.t(),
          area: integer(),
          population: integer(),
          continent: String.t(),
          tld: String.t(),
          currency_code: String.t(),
          currency_name: String.t(),
          phone: String.t(),
          postal_code_format: String.t(),
          postal_code_regex: String.t(),
          languages: String.t(),
          geoname_id: integer(),
          neighbours: String.t(),
          equivalent_fips_code: String.t()
        }
  schema "locations_countries" do
    field(:iso, :string, primary_key: true)
    field(:iso_3, :string)
    field(:iso_numeric, :integer)
    field(:fips, :string)
    field(:country_name, :string)
    field(:capital, :string)
    field(:area, :integer)
    field(:population, :integer)
    field(:continent, :string)
    field(:tld, :string)
    field(:currency_code, :string)
    field(:currency_name, :string)
    field(:phone, :string)
    field(:postal_code_format, :string)
    field(:postal_code_regex, :string)
    field(:languages, :string)
    field(:geoname_id, :integer)
    field(:neighbours, :string)
    field(:equivalent_fips_code, :string)

    timestamps()
  end

  @doc false
  def changeset(country, attrs) do
    country
    |> cast(attrs, [
      :iso,
      :iso_3,
      :iso_numeric,
      :fips,
      :country_name,
      :capital,
      :area,
      :population,
      :continent,
      :tld,
      :currency_code,
      :currency_name,
      :phone,
      :postal_code_format,
      :postal_code_regex,
      :languages,
      :geoname_id,
      :neighbours,
      :equivalent_fips_code
    ])
    |> validate_required([
      :iso,
      :iso_3,
      :iso_numeric,
      :country_name,
      :area,
      :population,
      :continent,
      :tld,
      :geoname_id
    ])
  end
end
