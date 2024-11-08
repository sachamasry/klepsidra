defmodule Klepsidra.Categorisation.ProjectTags do
  @moduledoc """
  Defines a schema for the `ProjectTags` entity, used to create a many-to-many
  relationship between projects and tags.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Klepsidra.Projects.Project
  alias Klepsidra.Categorisation.Tag

  @primary_key false
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          project_id: Ecto.UUID.t(),
          tag_id: Ecto.UUID.t()
        }
  schema "project_tags" do
    belongs_to(:project, Project, primary_key: true, type: Ecto.UUID)
    belongs_to(:tag, Tag, primary_key: true, type: Ecto.UUID)

    timestamps()
  end

  @doc false
  def changeset(project_tags, _attrs) do
    project_tags
    |> unique_constraint([:project, :tag],
      name: "project_tags_project_id_tag_id_index",
      message: "This tag has already been added to the project"
    )
    |> cast_assoc(:tag)
  end
end
