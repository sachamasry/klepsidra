defmodule Klepsidra.Categorisation.TimerTags do
  @moduledoc """
  Defines a schema for the `TimerTags` entity, used to create a many-to-many
  relationship between timers and tags.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Klepsidra.TimeTracking.Timer
  alias Klepsidra.Categorisation.Tag

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          tag_id: binary(),
          timer_id: binary()
        }
  schema "timer_tags" do
    belongs_to :tag, Tag, primary_key: true, type: Ecto.UUID
    belongs_to :timer, Timer, primary_key: true, type: Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(timer_tags, attrs) do
    timer_tags
    |> cast(attrs, [:tag_id, :timer_id])
    |> unique_constraint([:tag, :timer],
      name: "timer_tags_tag_id_timer_id_index",
      message: "This tag has already been added to the timer"
    )
    |> cast_assoc(:tag)
  end
end
