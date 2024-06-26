defmodule Klepsidra.TimeTracking.ActivityType do
  @moduledoc """
  Defines a schema for the `ActivityType` entity, used to set activity types on timers.

  Activity types are a way to preload billing defaults, to help calculate
  billing amounts at time of invoicing.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          activity_type: String.t(),
          billing_rate: number(),
          active: boolean()
        }
  schema "activity_types" do
    field :activity_type, :string
    field :billing_rate, :decimal
    field :active, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(activity_type, attrs) do
    activity_type
    |> cast(attrs, [:activity_type, :billing_rate, :active])
    |> validate_required([:activity_type])
  end
end
