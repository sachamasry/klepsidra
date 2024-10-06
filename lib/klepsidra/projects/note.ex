defmodule Klepsidra.Projects.Note do
  @moduledoc """
  Defines the schema for the project `notes` entity, annotations
  of ongoing management of projects.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          note: String.t(),
          project_id: binary()
        }
  schema "project_notes" do
    field :note, :string
    belongs_to :project, Project, type: Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(note, attrs) do
    note
    |> cast(attrs, [:note, :project_id])
    |> validate_required([:note], message: "The message can't be empty")
    |> assoc_constraint(:project)
  end
end
