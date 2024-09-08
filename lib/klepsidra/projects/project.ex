defmodule Klepsidra.Projects.Project do
  @moduledoc """
  Defines a schema for the `Projects` entity, used to label long-running projects.

  Projects can be initiated by both customers, as well as in response to supplier
  requirements, and can be linked to a `BusinessPartner` entity.

  Timers can also belong to projects, timing disparate activities as part of a
  long-running project.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Klepsidra.BusinessPartners.BusinessPartner

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          name: String.t(),
          description: String.t(),
          business_partner_id: binary(),
          active: boolean()
        }
  schema "projects" do
    field :name, :string
    field :description, :string
    field :active, :boolean, default: true

    belongs_to :business_partner, BusinessPartner, type: Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :description, :active])
    |> validate_required([:name], message: "Enter the project name")
    |> unique_constraint(:name,
      name: :projects_name_index,
      message: "A project with this name already exists"
    )
  end

  @doc """
  Used across live components to populate select options with projects.
  """
  @spec populate_projects_list() :: [Klepsidra.Projects.Project.t(), ...]
  def populate_projects_list() do
    [
      {"", ""}
      | Klepsidra.Projects.list_active_projects()
        |> Enum.map(fn project -> {project.name, project.id} end)
    ]
  end
end
