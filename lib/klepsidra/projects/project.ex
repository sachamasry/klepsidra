defmodule Klepsidra.Projects.Project do
  @moduledoc """
  Defines a schema for the `Projects` entity, used for grouping timers
  according to some long-running project leading to the activity being needed.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          name: String.t(),
          description: String.t(),
          active: boolean()
        }
  schema "projects" do
    field :active, :boolean, default: true
    field :name, :string
    field :description, :string

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :description, :active])
    |> validate_required([:name])
    |> unique_constraint(:name, name: :projects_name_index)
  end
end
