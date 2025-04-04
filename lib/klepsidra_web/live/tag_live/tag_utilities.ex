defmodule KlepsidraWeb.TagLive.TagUtilities do
  @moduledoc false

  use KlepsidraWeb, :live_component
  alias Klepsidra.Categorisation
  alias Klepsidra.Categorisation.Tag
  alias Klepsidra.DynamicCSS

  @doc """
  Format tag list to label/value map usable by `live_select` component.
  """
  @spec tag_options_for_live_select(tag_list :: [Tag.t(), ...]) :: [map, ...]
  def tag_options_for_live_select(tag_list) when is_list(tag_list) do
    tag_list
    |> Enum.map(fn tag ->
      %{
        label: tag.name,
        value: tag.id,
        description: tag.description || "",
        tag_class: "tag-#{DynamicCSS.convert_tag_name_to_class(tag.name)}",
        bg_colour: tag.colour || "#94a3b8",
        fg_colour: tag.fg_colour || "#fff"
      }
    end)
  end

  @doc """
  Handles creation of new freeform tags, and their immediate selection as
  a chosen tag for the entity.
  """
  @spec handle_free_tagging(
          socket :: Phoenix.LiveView.Socket.t(),
          tag_search_phrase :: String.t(),
          free_tag_length :: integer(),
          tag_select_id :: String.t(),
          tag_colour :: {String.t(), String.t()},
          options :: keyword()
        ) :: Phoenix.LiveView.Socket.t()
  def handle_free_tagging(
        socket,
        tag_search_phrase,
        free_tag_length,
        tag_select_id,
        tag_colour,
        options \\ []
      )

  def handle_free_tagging(
        socket,
        _tag_search_phrase,
        free_tag_length,
        _tag_select_id,
        _tag_colour,
        _options
      )
      when free_tag_length <= 2,
      do: socket

  def handle_free_tagging(
        socket,
        tag_search_phrase,
        _free_tag_length,
        tag_select_id,
        {bg_colour, fg_colour},
        _options
      ) do
    tag =
      Categorisation.create_or_find_tag(%{
        name: tag_search_phrase,
        colour: bg_colour,
        fg_colour: fg_colour
      })

    tags_applied = [tag.id | socket.assigns.selected_tag_queue]

    generate_tag_options(
      socket,
      socket.assigns.selected_tag_queue,
      tags_applied,
      tag_select_id
    )

    send_update(LiveSelect.Component,
      id: tag_select_id,
      options: []
    )

    socket
    |> assign(
      tag_search_phrase: nil,
      possible_free_tag_entered: false
    )
  end

  @doc """
  Takes list of tag IDs, returning full, tag-name sorted, HTML option list
  for `live_select` component.
  """
  @spec generate_tag_options(
          socket :: Phoenix.LiveView.Socket.t(),
          previous_tag_list :: [Ecto.UUID.t(), ...] | [],
          accumulated_tag_list :: [Ecto.UUID.t(), ...] | [],
          tag_select_id :: String.t(),
          options :: keyword()
        ) :: any()
  def generate_tag_options(
        socket,
        previous_tag_list,
        accumulated_tag_list,
        tag_select_id,
        options \\ []
      )

  def generate_tag_options(
        %{assigns: %{selected_tags: _selected_tags, selected_tag_queue: _selected_tag_queue}} =
          socket,
        previous_tag_list,
        previous_tag_list,
        _tag_select_id,
        _options
      ),
      do: socket

  def generate_tag_options(
        socket,
        previous_tag_list,
        previous_tag_list,
        _tag_select_id,
        _options
      ),
      do: assign(socket, selected_tags: [], selected_tag_queue: [])

  def generate_tag_options(
        socket,
        _previous_tag_list,
        accumulated_tag_list,
        tag_select_id,
        options
      ) do
    parent_tag_select_id = Keyword.get(options, :parent_tag_select_id, nil)

    tag_options =
      accumulated_tag_list
      |> Categorisation.get_tags!()
      |> tag_options_for_live_select()

    send_update(LiveSelect.Component, id: tag_select_id, value: tag_options)

    parent_tag_select_id &&
      send_update(LiveSelect.Component, id: parent_tag_select_id, value: tag_options)

    assign(socket, selected_tags: tag_options, selected_tag_queue: accumulated_tag_list)
  end
end
