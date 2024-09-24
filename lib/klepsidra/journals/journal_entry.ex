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
          location: String.t(),
          latitude: float(),
          longitude: float(),
          mood: String.t(),
          is_private: boolean(),
          is_short_entry: boolean(),
          is_scheduled: boolean(),
          user_id: integer(),
          category_id: integer()
        }
  schema "journal_entries" do
    field :journal_for, :string
    field :entry_text_markdown, :string
    field :entry_text_html, :string
    field :highlights, :string
    field :location, :string
    field :latitude, :float
    field :longitude, :float
    field :mood, :string
    field :is_private, :boolean, default: false
    field :is_short_entry, :boolean, default: false
    field :is_scheduled, :boolean, default: false
    belongs_to :user, Klepsidra.Accounts.User
    belongs_to :category, Klepsidra.Journals.Category

    timestamps()
  end

  @doc false
  def changeset(journal_entry, attrs) do
    journal_entry
    |> cast(attrs, [
      :journal_for,
      :entry_text_markdown,
      :entry_text_html,
      :highlights,
      :location,
      :latitude,
      :longitude,
      :mood,
      :is_private,
      :is_short_entry,
      :is_scheduled,
      :user_id,
      :category_id
    ])
    |> validate_required([
      :journal_for,
      :entry_text_markdown,
      :entry_text_html
    ])
  end
end
