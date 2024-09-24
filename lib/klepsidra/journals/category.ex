defmodule Klepsidra.Journals.Category do
  @moduledoc """
  Defines a schema for journals' `Category` entity, recording classifications of
  journals entries.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          name: String.t(),
          description: String.t()
        }
  schema "categories" do
    field :name, :string
    field :description, :string

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> unique_constraint(:name,
      name: :categories_name_index,
      message: "A category with this name already exists"
    )
  end
end
