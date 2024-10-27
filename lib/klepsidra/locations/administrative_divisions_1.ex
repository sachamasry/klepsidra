defmodule Klepsidra.Locations.AdministrativeDivisions1 do
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
          administrative_division_1_code: String.t(),
          country_code: String.t(),
          administrative_division_1_name: String.t(),
          administrative_division_1_ascii_name: String.t(),
          geoname_id: integer()
        }
  schema "locations_administrative_divisions_1" do
    field(:administrative_division_1_code, :string, primary_key: true)
    field(:country_code, :string)
    field(:administrative_division_1_name, :string)
    field(:administrative_division_1_ascii_name, :string)
    field(:geoname_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(administrative_divisions_1, attrs) do
    administrative_divisions_1
    |> cast(attrs, [
      :administrative_division_1_code,
      :country_code,
      :administrative_division_1_name,
      :administrative_division_1_ascii_name,
      :geoname_id
    ])
    |> unique_constraint(:administrative_division_1_code)
    |> foreign_key_constraint(:country_code)
    |> validate_required([
      :administrative_division_1_code,
      :country_code,
      :administrative_division_1_name,
      :administrative_division_1_ascii_name,
      :geoname_id
    ])
  end
end
