defmodule Klepsidra.TimeTracking.Note do
  @moduledoc """
  Defines the data schema for the `Note` entity, annotations of timed activities.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          note: String.t(),
          timer_id: binary()
        }
  schema "timer_notes" do
    field :note, :string
    belongs_to :timer, Klepsidra.TimeTracking.Timer, type: Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(note, attrs) do
    note
    |> cast(attrs, [:note, :timer_id])
    |> validate_required([:note])
    |> assoc_constraint(:timer)
  end
end
