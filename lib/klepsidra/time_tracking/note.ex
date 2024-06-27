defmodule Klepsidra.TimeTracking.Note do
  @moduledoc """
  Defines the data schema for the `Note` entity, annotations of timed activities.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  @type t :: %__MODULE__{
          note: String.t(),
          user_id: integer,
          timer_id: integer
        }
  schema "timer_notes" do
    field :note, :string
    field :user_id, :integer, default: nil
    field :timer_id, :id

    timestamps()
  end

  @doc false
  def changeset(note, attrs) do
    note
    |> cast(attrs, [:note, :user_id, :timer_id])
    |> validate_required([:note])
  end
end
