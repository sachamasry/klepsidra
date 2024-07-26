defmodule Klepsidra.Categorisation.Tag do
  @moduledoc """
  Defines a schema for the `Tags` entity, used for categorising timed activities
  with free form tags.

  To provide a helpful flourish which will make selected tags stand out, we include a
  `colour` field.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Klepsidra.Categorisation.TimerTags

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          name: String.t(),
          description: String.t(),
          colour: String.t(),
          fg_colour: String.t()
        }
  schema "tags" do
    field :name, :string
    field :description, :string
    field :colour, :string
    field :fg_colour, :string

    timestamps()

    many_to_many :timers, TimerTags, join_through: "timer_tags"
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :description, :colour, :fg_colour])
    |> validate_required([:name], message: "Enter a tag name")
    |> unique_constraint(:name,
      name: :tags_name_index,
      message: "A tag with this name already exists"
    )
  end
end
