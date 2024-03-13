defmodule Klepsidra.TimeTracking.Timer do
  use Ecto.Schema
  import Ecto.Changeset
  alias Klepsidra.Categorisation.Tag 

  schema "timers" do
    field :description, :string
    field :start_stamp, :string
    field :end_stamp, :string
    field :duration, :integer, default: 0
    field :duration_time_unit, :string
    field :reported_duration, :integer
    field :reported_duration_time_unit, :string

    belongs_to :tag, Tag

    timestamps()
  end

  @doc false
  def changeset(timer, attrs) do
    timer
    |> cast(attrs, [:start_stamp, :end_stamp, :duration, :duration_time_unit, :reported_duration, :reported_duration_time_unit, :description, :tag_id])
    |> validate_required([:start_stamp])
    |> unique_constraint(:tag)
  end
end
