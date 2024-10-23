defmodule Klepsidra.Locations.FeatureCode do
  @moduledoc """
  Defines a schema for the `FeatureCode` entity, listing GeoNames'
  feature classes and codes, categorising locations around the world. This
  data is used in their cities database.

  This is not meant to be a user-editable entity, imported on a periodic basis
  from the [Geonames](https://geonames.org) project, specifically the `featureCodes.txt`
  file, with column headers converted to lowercase, underscore-separated names.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @type t :: %__MODULE__{
          feature_code: String.t(),
          feature_class: String.t(),
          order: integer(),
          description: String.t(),
          note: String.t()
        }
  schema "locations_feature_codes" do
    field(:feature_code, :string, primary_key: true)
    field(:feature_class, :string)
    field(:order, :integer)
    field(:description, :string)
    field(:note, :string)

    timestamps()
  end

  @doc false
  def changeset(feature_code, attrs) do
    feature_code
    |> cast(attrs, [:feature_code, :feature_class, :description, :note, :order])
    |> unique_constraint(:feature_code,
      name: :locations_feature_codes_feature_code_index
    )
    |> foreign_key_constraint(:feature_class,
      name: :FK_locations_feature_codes_locations_feature_classes
    )
    |> validate_required([:feature_code, :feature_class, :order, :description])
  end
end
