defmodule Klepsidra.Locations.AdministrativeDivision1 do
  @moduledoc """
  Defines a schema for the `AdministrativeDivision1` entity, listing GeoNames'
  country code and administrative division 1 codes, data that is used in
  their cities database.

  This is not meant to be a user-editable entity, imported on a periodic basis
  from the [Geonames](https://geonames.org) project, specifically the
  `admin1CodesASCII.txt` file, with column headers inserted.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @type t :: %__MODULE__{
          country_code: String.t(),
          administrative_division_code: String.t(),
          c_code: String.t(),
          administrative_division_name: String.t(),
          administrative_division_name_ascii: String.t(),
          geoname_id: integer()
        }
  schema "locations_administrative_division1" do
    field(:country_code, :string, primary_key: true)
    field(:administrative_division_code, :string, primary_key: true)
    field(:c_code, :string)
    field(:administrative_division_name, :string)
    field(:administrative_division_name_ascii, :string)
    field(:geoname_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(administrative_division1, attrs) do
    administrative_division1
    |> cast(attrs, [
      :country_code,
      :administrative_division_code,
      :c_code,
      :administrative_division_name,
      :administrative_division_name_ascii,
      :geoname_id
    ])
    |> foreign_key_constraint(:c_code,
      name: :FK_locations_administrative_division1_locations_countries
    )
    |> validate_required([
      :country_code,
      :administrative_division_code,
      :c_code,
      :administrative_division_name,
      :administrative_division_name_ascii,
      :geoname_id
    ])
  end
end
