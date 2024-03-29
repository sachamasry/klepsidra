defmodule Klepsidra.Categorisation.Tag do
  @moduledoc """
  Defines a schema for the `Tags` entity, used for categorising timed activities
  with free form tags.

  To provide a helpful flourish which will make selected tags stand out, we include a 
  `colour` field.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :name, :string
    field :description, :string
    field :colour, :string

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :colour, :description])
    |> validate_required([:name])
  end
end
