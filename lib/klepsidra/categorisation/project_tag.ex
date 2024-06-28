defmodule Klepsidra.Categorisation.ProjectTag do
  @moduledoc """
  Defines a schema for the `ProjectTags` entity, used to create a many-to-many
  relationship between projects and tags.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Klepsidra.Projects.Project
  alias Klepsidra.Categorisation.Tag

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          tag_id: binary(),
          project_id: binary()
        }
  schema "project_tags" do
    belongs_to :tag, Tag, primary_key: true, type: Ecto.UUID
    belongs_to :project, Project, primary_key: true, type: Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(project_tag, attrs) do
    project_tag
    |> cast(attrs, [:tag_id, :project_id])
    |> unique_constraint([:tag, :project], name: "project_tags_tag_id_project_id_index")
    |> cast_assoc(:tag)
  end
end
