defmodule Klepsidra.Locations.FeatureCode do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @type t :: %__MODULE__{
          feature_class: String.t(),
          feature_code: String.t(),
          description: String.t(),
          note: String.t(),
          order: integer()
        }
  schema "locations_feature_codes" do
    field(:feature_class, :string, primary_key: true)
    field(:feature_code, :string, primary_key: true)
    field(:description, :string)
    field(:note, :string)
    field(:order, :integer)

    timestamps()
  end

  @doc false
  def changeset(feature_code, attrs) do
    feature_code
    |> cast(attrs, [:feature_class, :feature_code, :description, :note, :order])
    |> unique_constraint([:feature_class, :feature_code],
      name: :locations_feature_codes_feature_class_feature_code_index
    )
    |> validate_required([:feature_class, :feature_code, :order])
  end
end
