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

  alias Klepsidra.Categorisation.Tag

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
    |> validate_required([:title, :content, :content_format, :status, :pinned])
    |> generate_html_entry()
  end

  @doc """
  Early in the validation chain, ensuring that validity of all necessary fields
  hasn't been checked yet, convert all text written in the markdown field to clean
  HTML.
  """
  def generate_html_entry(%{valid?: true, changes: %{content: content}} = changeset) do
    put_change(changeset, :rendered_content, convert_markdown_to_html(content))
  end

  def generate_html_entry(changeset), do: changeset

  @doc """
  Take in markdown-formatted text, converting it to HTML.
  """
  def convert_markdown_to_html(markdown_string) when is_bitstring(markdown_string) do
    Earmark.as_html!(markdown_string,
      breaks: true,
      code_class_prefix: "lang- language-",
      compact_output: false,
      escape: false,
      footnotes: true,
      gfm_tables: true,
      smartypants: true,
      sub_sup: true
    )
    |> HtmlSanitizeEx.html5()
  end
end