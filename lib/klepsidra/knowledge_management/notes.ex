defmodule Klepsidra.KnowledgeManagement.Note do
  @moduledoc """
  Defines the `Note` schema needed to record users notes.

  This entity records standalone and versatile notes of broader
  thematic potential, such as (but not limited to) thoughts,
  research insights, concepts, reflections, synthesis or summaries
  not necessarily linked to a particular citation or source.

  Notes are primary units of thought and knowledge, which can interlink,
  forming a knowledge base.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          title: String.t(),
          content: String.t(),
          content_format: String.t(),
          rendered_content: String.t(),
          rendered_content_format: String.t(),
          summary: String.t(),
          status: atom(),
          review_date: Date.t(),
          pinned: boolean(),
          attachments: map(),
          priority: integer()
        }
  schema "knowledge_management_notes" do
    field :title, :string
    field :content, :string
    field :content_format, Ecto.Enum, values: [:markdown, :"org-mode", :plaintext]
    field :rendered_content, :string
    field :rendered_content_format, Ecto.Enum, values: [:html, :pdf, :plaintext]
    field :summary, :string
    field :status, Ecto.Enum, values: [:draft, :fleeting, :evergreen, :archived]
    field :review_date, :date
    field :pinned, :boolean, default: false
    field :attachments, :map
    field :priority, :integer

    timestamps()
  end

  @doc false
  def changeset(notes, attrs) do
    notes
    |> cast(attrs, [
      :title,
      :content,
      :content_format,
      :rendered_content,
      :rendered_content_format,
      :summary,
      :status,
      :review_date,
      :pinned,
      :attachments,
      :priority
    ])
    |> validate_required([:title, :content, :content_format, :status, :pinned])
  end
end
