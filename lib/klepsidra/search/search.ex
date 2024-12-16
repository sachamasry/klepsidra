defmodule Klepsidra.Search.UnifiedSearch do
  @moduledoc """
  Defines the `UnifiedSearch` schema needed to index system
  entities for full-text search.

  This schema ingests all string fields from a wide range of
  entities benefiting from searching:

  * `entity_id` (actual primary key ID for the entity)
  * `entity, category`
  * `status`
  * `owner_id`
  * `group_id`
  * `title`
  * `subtitle`
  * `author`
  * `tags` (concatenated string list of tag names, for additional discoverability)
  * `location`
  * `text` (main entity content field, concatenated with additional field
            values for enhanced search)
  * `inserted_at`
  * `updated_at`

  as well as `rowid`, based on each table's native `rowid` value, with a
  large integer added to it, for entity partitioning.

  The search schema refers to the external view `unified_search_view` for
  purposes of generating _trigram_ idexes on all the above fields,
  providing substring searching ability.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true, source: :rowid}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          entity_id: Ecto.UUID.t(),
          entity: String.t(),
          category: String.t(),
          status: String.t(),
          owner_id: Ecto.UUID.t(),
          group_id: Ecto.UUID.t(),
          title: String.t(),
          subtitle: String.t(),
          author: String.t(),
          tags: String.t(),
          location: String.t(),
          text: String.t()
        }
  schema "unified_search" do
    field :entity_id, Ecto.UUID
    field :entity, :string
    field :category, :string
    field :status, :string
    field :owner_id, Ecto.UUID
    field :group_id, Ecto.UUID
    field :title, :string
    field :subtitle, :string
    field :author, :string
    field :tags, :string
    field :location, :string
    field :text, :string
  end

  @doc false
  def changeset(search, attrs) do
    search
    |> cast(attrs, [
      :entity_id,
      :entity,
      :category,
      :status,
      :owner_id,
      :group_id,
      :title,
      :subtitle,
      :author,
      :tags,
      :location,
      :text
    ])
    |> validate_required([:id, :entity_id])
  end
end
