defmodule Klepsidra.Categorisation.TimerTags do
  @moduledoc """
  Defines a schema for the `TimerTags` entity, used to create a many-to-many
  relationship between timers and tags.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Klepsidra.TimeTracking.Timer
  alias Klepsidra.Categorisation.Tag

  @primary_key false
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          timer_id: Ecto.UUID.t(),
          tag_id: Ecto.UUID.t()
        }
  schema "timer_tags" do
    belongs_to(:timer, Timer, primary_key: true, type: Ecto.UUID)
    belongs_to(:tag, Tag, primary_key: true, type: Ecto.UUID)

    timestamps()
  end

  @doc false
  def changeset(timer_tags, _attrs) do
    timer_tags
    |> unique_constraint([:timer, :tag],
      name: "timer_tags_timer_id_tag_id_index",
      message: "This tag has already been added to the timer"
    )
    |> cast_assoc(:tag)
  end
end
