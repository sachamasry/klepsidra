defmodule Klepsidra.Journals.JournalEntry do
  @moduledoc """
  Defines the `journal_entries` schema needed to record a generic set of journaling
  needs, from the deeply personal, to commercial.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          journal_for: String.t(),
          entry_text_markdown: String.t(),
          entry_text_html: String.t(),
          highlights: String.t(),
          entry_type_id: integer(),
          location: String.t(),
          latitude: float(),
          longitude: float(),
          mood: String.t(),
          is_private: boolean(),
          is_short_entry: boolean(),
          is_scheduled: boolean(),
          user_id: integer()
        }
  schema "journal_entries" do
    field(:journal_for, :string)
    field(:entry_text_markdown, :string)
    field(:entry_text_html, :string)
    field(:highlights, :string)
    belongs_to(:entry_type, Klepsidra.Journals.JournalEntryTypes)
    field(:location, :string, default: "")
    field(:latitude, :float, default: nil)
    field(:longitude, :float, default: nil)
    field(:mood, :string, default: "")
    field(:is_private, :boolean, default: false)
    field(:is_short_entry, :boolean, default: false)
    field(:is_scheduled, :boolean, default: false)
    belongs_to(:user, Klepsidra.Accounts.User)

    timestamps()
  end

  @doc false
  def changeset(journal_entry, attrs) do
    journal_entry
    |> cast(attrs, [
      :journal_for,
      :entry_text_markdown,
      :entry_text_html,
      :entry_type_id,
      :highlights,
      :location,
      :latitude,
      :longitude,
      :mood,
      :is_private,
      :is_short_entry,
      :is_scheduled,
      :user_id
    ])
    |> generate_html_entry()
    |> validate_required(:journal_for, message: "Enter the date this journal is for")
    |> validate_required(:entry_text_html, message: "You must write your journal entry")
    |> validate_required(:entry_type_id,
      message: "Please select what type of journal entry you're logging"
    )
    |> assoc_constraint(:entry_type)
  end

  @doc """
  Early in the validation chain, ensuring that validity of all necessary fields
  hasn't been checked yet, convert all text written in the markdown field to clean
  HTML.
  """
  def generate_html_entry(
        %{valid?: true, changes: %{entry_text_markdown: entry_text_markdown}} = changeset
      ) do
    put_change(changeset, :entry_text_html, convert_markdown_to_html(entry_text_markdown))
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
