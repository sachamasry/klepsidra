defmodule Klepsidra.Locations.City do
  @moduledoc """
  Defines a schema for the `City` entity, used to select cities of the world.

  This is not meant to be a user-editable entity, imported on a periodic basis
  from the [Geonames](https://geonames.org) project, specifically the `cities500.zip`
  file, all cities with a population greater than 500.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          geoname_id: integer(),
          name: String.t(),
          ascii_name: String.t(),
          alternate_names: String.t(),
          latitude: float(),
          longitude: float(),
          feature_class: String.t(),
          feature_code: String.t(),
          country_code: String.t(),
          cc2: String.t(),
          administrative_division_1_code: String.t(),
          administrative_division_2_code: String.t(),
          administrative_division_3_code: String.t(),
          administrative_division_4_code: String.t(),
          population: integer(),
          elevation: integer(),
          dem: integer(),
          timezone: String.t(),
          modification_date: Date.t()
        }
  schema "locations_cities" do
    field(:geoname_id, :integer)
    field(:name, :string)
    field(:ascii_name, :string)
    field(:alternate_names, :string)
    field(:latitude, :float)
    field(:longitude, :float)

    field(:feature_class, :binary_id)
    # field(:feature_code, :binary_id)
    belongs_to(:feature_code, FeatureCode, references: :feature_code, type: :binary_id)

    field(:country_code, :string)
    field(:cc2, :string)
    field(:administrative_division_1_code, :string)
    field(:administrative_division_2_code, :string)
    field(:administrative_division_3_code, :string)
    field(:administrative_division_4_code, :string)
    field(:population, :integer)
    field(:elevation, :integer)
    field(:dem, :integer)
    field(:timezone, :string)
    field(:modification_date, :date)

    timestamps()
  end

  @doc false
  def changeset(city, attrs) do
    city
    |> cast(attrs, [
      :geoname_id,
      :name,
      :asciiname,
      :alternatenames,
      :latitude,
      :longitude,
      :feature_class,
      :feature_code,
      :country_code,
      :cc2,
      :administrative_division_1_code,
      :administrative_division_2_code,
      :administrative_division_3_code,
      :administrative_division_4_code,
      :population,
      :elevation,
      :dem,
      :timezone,
      :modification_date
    ])
    |> unique_constraint([:geoname_id],
      name: :locations_cities_geoname_id_index
    )
    |> foreign_key_constraint(:administrative_divisions_1,
      name: :FK_locations_cities_locations_administrative_divisions_1
    )
    |> foreign_key_constraint(:administrative_divisions_2,
      name: :FK_locations_cities_locations_administrative_divisions_2_2
    )
    |> foreign_key_constraint(:country_code,
      name: :FK_locations_cities_locations_countries_3
    )
    |> foreign_key_constraint(:feature_code,
      name: :FK_locations_cities_locations_feature_codes_4
    )
    |> validate_required([
      :geoname_id,
      :name,
      :latitude,
      :longitude,
      :feature_class,
      :feature_code,
      :country_code,
      :population,
      :timezone,
      :modification_date
    ])
  end
end
