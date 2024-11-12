defmodule Klepsidra.KnowledgeManagement.Annotation do
  @moduledoc """
  Defines the `annotations` schema, for recording annotations and quotes
  from source material.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          entry_type: String.t(),
          text: String.t(),
          author_name: String.t(),
          comment: String.t(),
          position_reference: String.t()
        }
  schema "annotations" do
    field(:entry_type, :string)
    field(:text, :string)
    field(:author_name, :string)
    field(:comment, :string)
    field(:position_reference, :string)

    timestamps()
  end

  @doc false
  def changeset(annotation, attrs) do
    annotation
    |> cast(attrs, [:entry_type, :text, :author_name, :comment, :position_reference])
    |> validate_required([:entry_type, :text])
  end
end
