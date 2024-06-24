defmodule Klepsidra.Categorisation.ProjectTag do
  @moduledoc """
  Defines a schema for the `ProjectTags` entity, used to create a many-to-many
  relationship between projects and tags.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Klepsidra.Projects.Project
  alias Klepsidra.Categorisation.Tag

  @type t :: %__MODULE__{
          tag_id: integer(),
          project_id: integer()
        }
  schema "project_tags" do
    belongs_to :tag, Tag, primary_key: true
    belongs_to :project, Project, primary_key: true

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
