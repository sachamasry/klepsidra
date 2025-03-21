defmodule KlepsidraWeb.RelatedEntityComponents do
  @moduledoc false

  use KlepsidraWeb, :live_component

  attr(:title, :string, default: "Links")

  attr(:relation_direction, :atom,
    values: [:outbound, :inbound],
    default: :outbound,
    doc:
      "Defines whether the relationship stems out from this entity to the related one `:outbound`, or back in from the related entity `:inbound`"
  )

  attr(:related_entities, :list,
    required: true,
    doc: "List of related entities to pass to Phoenix.HTML.Form.options_for_select/2"
  )

  attr(:related_entity_count, :integer, default: 0, doc: "Count of all related entities")

  def relation_listing(assigns) do
    ~H"""
    <section :if={@related_entities != []} class="rounded-2xl my-6 p-6 bg-peach-fuzz-lightness-105">
      <h3 class="font-extrabold text-violet-900/50 col-span-2">
        {@title} ({@related_entity_count})
      </h3>

      <div
        phx-update="stream"
        id={"#{@relation_direction}-related-entities"}
        class="grid grid-cols-2 gap-6 mt-4"
      >
        <.related_entity
          :for={{dom_id, related_entity} <- @related_entities}
          id={dom_id}
          relation_direction={@relation_direction}
          entity={related_entity}
          title={related_entity.title}
        />
      </div>
    </section>
    """
  end

  attr(:id, :string, required: true)

  attr(:relation_direction, :atom,
    values: [:outbound, :inbound],
    default: :outbound,
    doc:
      "Defines whether the relationship stems out from this entity to the related one `:outbound`, or back in from the related entity `:inbound`"
  )

  attr(:title, :string, required: true, doc: "Primary title for the related entity")

  attr :entity, :map, required: true

  def related_entity(assigns) do
    ~H"""
    <article
      id={@id}
      name={@title}
      class="group/entity relative col-span-1 rounded-lg max-h-48 overflow-clip p-6 bg-peach-fuzz-lightness-75 hover:bg-peach-fuzz-600 hover:cursor-pointer hover:text-white"
      title={@entity.properties}
    >
      <.link
        phx-click={
          JS.push("delete-#{@relation_direction}",
            value: %{
              dom_id: @id,
              source_note_id: @entity.source_note_id,
              target_note_id: @entity.target_note_id,
              relationship_type_id: @entity.relationship_type_id
            }
          )
          |> hide("##{@id}")
        }
        data-confirm="Are you sure you want to delete this relationship?"
        class="group/unlink absolute right-5 top-5 h-6 w-6 hover:bg-rose-100 rounded-md"
      >
        <.icon
          name="hero-trash"
          class="relative h-4 w-4 inset-1/2 align-top -translate-x-1/2 -translate-y-1/2 bg-peach-fuzz-lightness-75 group-hover/unlink:bg-rose-600"
        />
      </.link>
      <.link navigate={~p"/knowledge_management/notes/#{@entity.id}"} class="">
        <header>
          <h5 class="uppercase text-xs text-peach-fuzz-500 group-hover/entity:text-white">
            <.icon :if={@relation_direction == :inbound} name="hero-arrow-long-left" class="h-4 w-4" />
            {if(@relation_direction == :inbound,
              do: @entity.reverse_relationship_type,
              else: @entity.relationship_type
            )}
            <.icon
              :if={@relation_direction == :outbound}
              name="hero-arrow-long-right"
              class="h-4 w-4"
            />
          </h5>
          <h4 class="font-semibold mb-4">
            {@entity.title}
          </h4>
          <div :if={@entity.summary} class="line-clamp-2 mb-4 italic">
            {@entity.summary}
          </div>
        </header>
        <div class={if(@entity.summary, do: "line-clamp-2", else: "line-clamp-4")}>
          {@entity.content |> Phoenix.HTML.raw()}
        </div>
      </.link>
    </article>
    """
  end
end
