defmodule Klepsidra.Categorisation.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :name, :string
    field :tag, :string
    field :description, :string
    field :colour, :string

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:tag, :name, :colour, :description])
    |> validate_required([:tag])
  end
end
