defmodule Klepsidra.TimeTracking.ActivityType do
  @moduledoc """
  Defines a schema for the `ActivityType` entity, used to set activity types on timers.

  Activity types are a way to preload billing defaults, to help calculate
  billing amounts at time of invoicing.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          name: String.t(),
          billing_rate: number(),
          active: boolean()
        }
  schema "activity_types" do
    field :name, :string
    field :billing_rate, :decimal
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(activity_type, attrs) do
    activity_type
    |> cast(attrs, [:name, :billing_rate, :active])
    |> validate_required([:name], message: "Enter an activity type name")
    |> unique_constraint(:name, message: "An activity type with this name already exists")
    |> validate_required([:billing_rate], message: "The hourly billing rate must be a number")
    |> validate_number(:billing_rate,
      greater_than_or_equal_to: 0,
      message: "The billing rate must be zero or greater"
    )
  end

  @doc """
  Used across live components to populate select options with activity types.
  """
  @spec populate_activity_types_list() :: [Klepsidra.TimeTracking.ActivityType.t(), ...]
  def populate_activity_types_list() do
    [
      {"", ""}
      | Klepsidra.TimeTracking.list_activity_types()
        |> Enum.map(fn type -> {type.name, type.id} end)
    ]
  end
end
