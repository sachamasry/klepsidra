defmodule KlepsidraWeb.TagLive.TagUtilities do
  @moduledoc false

  use KlepsidraWeb, :live_component
  alias Klepsidra.Categorisation
  alias Klepsidra.Categorisation.Tag

  @doc """
  Handles creation of new freeform tags, and their immediate selection as
  a chosen tag for the entity.
  """
  @spec handle_free_tagging(
          tag_search_phrase :: String.t(),
          free_tag_length :: integer(),
          live_select_id :: String.t(),
          socket :: Phoenix.LiveView.Socket.t()
        ) :: Phoenix.LiveView.Socket.t()
  def handle_free_tagging(_tag_search_phrase, free_tag_length, _live_select_id, socket)
      when free_tag_length <= 2,
      do: socket

  def handle_free_tagging(tag_search_phrase, _free_tag_length, live_select_id, socket) do
    tag = Categorisation.create_or_find_tag(%{name: tag_search_phrase})

    tags_applied = [tag.id | socket.assigns.selected_tag_queue]

    generate_tag_options(
      socket.assigns.selected_tag_queue,
      tags_applied,
      live_select_id,
      socket
    )

    send_update(LiveSelect.Component,
      id: live_select_id,
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
          previous_tag_list :: [Ecto.UUID.t(), ...] | [],
          accumulated_tag_list :: [Ecto.UUID.t(), ...] | [],
          live_select_id :: String.t(),
          socket :: Phoenix.LiveView.Socket.t()
        ) :: any()
  def generate_tag_options(
        previous_tag_list,
        previous_tag_list,
        _live_select_id,
        %{assigns: %{selected_tags: _selected_tags, selected_tag_queue: _selected_tag_queue}} =
          socket
      ),
      do: socket

  def generate_tag_options(previous_tag_list, previous_tag_list, _live_select_id, socket),
    do: assign(socket, selected_tags: [], selected_tag_queue: [])

  def generate_tag_options(_previous_tag_list, accumulated_tag_list, live_select_id, socket) do
    tag_options =
      accumulated_tag_list
      |> Categorisation.get_tags!()
      |> Tag.tag_options_for_live_select()

    send_update(LiveSelect.Component, id: live_select_id, value: tag_options)

    assign(socket, selected_tags: tag_options, selected_tag_queue: accumulated_tag_list)
  end
end