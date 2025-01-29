defmodule Klepsidra.KnowledgeManagement.Note do
  @moduledoc """
  Defines the `Note` schema needed to record user notes.

  This entity records standalone and versatile notes of broader
  thematic potential, such as (but not limited to) thoughts,
  research insights, concepts, reflections, synthesis or summaries
  not necessarily linked to a particular citation or source.

  Notes are primary units of thought and knowledge, which can interlink,
  forming a knowledge base.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Klepsidra.Categorisation.Tag
  alias Klepsidra.Markdown

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
    field :content_format, Ecto.Enum, values: [:markdown, :"org-mode", :wikitext, :plaintext]
    field :rendered_content, :string
    field :rendered_content_format, Ecto.Enum, values: [:html, :markdown, :pdf, :plaintext]
    field :summary, :string

    field :status, Ecto.Enum,
      values: [:fleeting, :literature, :reference, :permanent, :hub, :archived]

    field :review_date, :date
    field :pinned, :boolean, default: false
    field :attachments, :map
    field :priority, :integer

    many_to_many(:tags, Tag,
      join_through: "knowledge_management_note_tags",
      on_replace: :delete,
      preload_order: [asc: :name]
    )

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
    |> validate_required([:title], message: "Enter a title for this note")
    |> validate_required([:content], message: "Write the content of the note")
    |> validate_required([:content_format, :status, :pinned])
    |> validate_required([:title, :content, :content_format, :status, :pinned])
    |> generate_html_entry()
  end

  @doc """
  Early in the validation chain, ensuring that validity of all necessary fields
  hasn't been checked yet, convert all text written in the markdown field to clean
  HTML.
  """
  def generate_html_entry(%{valid?: true, changes: %{content: content}} = changeset) do
    case Markdown.to_html(content) do
      {:ok, html_content} ->
        put_change(changeset, :rendered_content, html_content)

      {_, _} ->
        changeset
    end
  end

  def generate_html_entry(changeset), do: changeset
end
