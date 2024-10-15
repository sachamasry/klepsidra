defmodule Klepsidra.Locations.FeatureClass do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:feature_class, :binary_id, autogenerate: false}

  @type t :: %__MODULE__{
          feature_code: String.t(),
          feature_class: String.t(),
          description: String.t(),
          note: String.t(),
          order: integer()
        }
  schema "locations_feature_classes" do
    field :feature_code, :string
    field :description, :string
    field :note, :string
    field :order, :integer

    timestamps()
  end

  @doc false
  def changeset(feature_class, attrs) do
    feature_class
    |> cast(attrs, [:feature_code, :feature_class, :description, :note, :order])
    |> validate_required([:feature_code, :feature_class, :order])
  end
end
