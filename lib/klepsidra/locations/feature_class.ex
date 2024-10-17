defmodule Klepsidra.Locations.FeatureClass do
  @moduledoc """
  Defines a schema for the `FeatureClass` entity, listing GeoNames'
  feature classes, used for categorising locations around the world.
  This data is used in their cities database.

  This is not meant to be a user-editable entity, imported on a periodic basis
  from the [Geonames](https://geonames.org) project, specifically the
  `feature_classes.csv` file (itself generated from the description on
  https://download.geonames.org/export/dump/), with column headers added.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @type t :: %__MODULE__{
          feature_class: String.t(),
          description: String.t()
        }
  schema "locations_feature_classes" do
    field :description, :string, primary_key: true
    field :feature_class, :string

    timestamps()
  end

  @doc false
  def changeset(feature_class, attrs) do
    feature_class
    |> cast(attrs, [:feature_class, :description])
    |> validate_required([:feature_class])
  end
end
