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
          feature_class: String.t(),
          feature_code: String.t(),
          order: integer(),
          f_class: String.t(),
          description: String.t(),
          note: String.t()
        }
  schema "locations_feature_codes" do
    field(:feature_class, :string, primary_key: true)
    field(:feature_code, :string, primary_key: true)
    field(:order, :integer)
    field(:f_class, :string)
    field(:description, :string)
    field(:note, :string)

    timestamps()
  end

  @doc false
  def changeset(feature_code, attrs) do
    feature_code
    |> cast(attrs, [:feature_class, :feature_code, :f_class, :description, :note, :order])
    |> unique_constraint([:feature_class, :feature_code],
      name: :locations_feature_codes_feature_class_feature_code_index
    )
    |> foreign_key_constraint(:f_class,
      name: :FK_locations_feature_codes_locations_feature_classes
    )
    |> validate_required([:feature_class, :feature_code, :order])
  end
end
