defmodule KlepsidraWeb.TripLive.FormComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component
  import LiveToast

  alias Klepsidra.Accounts
  alias Klepsidra.Documents
  alias Klepsidra.Locations
  alias Klepsidra.Travel
  alias Klepsidra.Locations.Country

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle></:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="trip-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.live_select
          field={@form[:user_id]}
          mode={:single}
          label="User"
          allow_clear
          options={[]}
          placeholder="Which user took this trip?"
          debounce={200}
          dropdown_extra_class="bg-white max-h-48 overflow-y-scroll"
          update_min_len={2}
          value_mapper={&user_value_mapper/1}
          phx-target={@myself}
        >
          <:option :let={option}>
            <div class="flex">
              <%= option.label %>
            </div>
          </:option>
        </.live_select>

        <.live_select
          field={@form[:user_document_id]}
          mode={:single}
          label="Travel document"
          allow_clear
          options={[]}
          placeholder="Which travel document was used to travel to country?"
          debounce={200}
          dropdown_extra_class="bg-white max-h-48 overflow-y-scroll"
          update_min_len={2}
          value_mapper={&user_document_value_mapper/1}
          phx-target={@myself}
        >
          <:option :let={option}>
            <div class="flex">
              <%= option.label %>
            </div>
          </:option>
        </.live_select>

        <.live_select
          field={@form[:country_id]}
          mode={:single}
          label="Destination country"
          allow_clear
          options={[]}
          placeholder="Country travelled to"
          debounce={200}
          dropdown_extra_class="bg-white max-h-48 overflow-y-scroll"
          update_min_len={2}
          value_mapper={&country_value_mapper/1}
          phx-target={@myself}
        >
          <:option :let={option}>
            <div class="flex">
              <%= option.label %>
            </div>
          </:option>
        </.live_select>

        <.input field={@form[:entry_date]} type="date" label="Entry date" />
        <.input field={@form[:exit_date]} type="date" label="Exit date" />
        <.input
          field={@form[:description]}
          type="textarea"
          label="Description"
          placeholder="Additional notes, e.g. trip purpose, context, key events during the trip"
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save trip</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{trip: trip} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Travel.change_trip(trip))
     end)}
  end

  @impl true
  def handle_event(
        "live_select_change",
        %{
          "field" => "trip_user_id",
          "id" => live_select_id,
          "text" => user_name_search_phrase
        },
        socket
      ) do
    users =
      Accounts.list_users_options_for_select_matching_name(user_name_search_phrase)

    send_update(LiveSelect.Component, id: live_select_id, options: users)
    {:noreply, socket}
  end

  def handle_event(
        "live_select_change",
        %{
          "field" => "trip_user_document_id",
          "id" => live_select_id,
          "text" => user_document_name_search_phrase
        },
        socket
      ) do
    user_documents =
      Documents.list_user_documents_options_for_select_valid_matching_name(
        user_document_name_search_phrase
      )

    send_update(LiveSelect.Component, id: live_select_id, options: user_documents)
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "live_select_change",
        %{
          "field" => "trip_country_id",
          "id" => live_select_id,
          "text" => country_search_phrase
        },
        socket
      ) do
    countries = Locations.country_search(country_search_phrase)

    send_update(LiveSelect.Component, id: live_select_id, options: countries)
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"trip" => trip_params}, socket) do
    changeset = Travel.change_trip(socket.assigns.trip, trip_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"trip" => trip_params}, socket) do
    save_trip(socket, socket.assigns.action, trip_params)
  end

  defp save_trip(socket, :edit, trip_params) do
    case Travel.update_trip(socket.assigns.trip, trip_params) do
      {:ok, trip} ->
        trip = Travel.get_trip_with_user_and_country(trip.id)
        notify_parent({:saved, trip})

        {:noreply,
         socket
         |> put_toast(:info, "Trip updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_trip(socket, :new, trip_params) do
    case Travel.create_trip(trip_params) do
      {:ok, trip} ->
        trip = Travel.get_trip_with_user_and_country(trip.id)
        notify_parent({:saved, trip})

        {:noreply,
         socket
         |> put_toast(:info, "Trip created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp user_value_mapper(user_id)
       when is_bitstring(user_id) do
    Accounts.get_user_option_for_select(user_id)
  end

  defp user_value_mapper(value), do: value

  defp user_document_value_mapper(user_document_id)
       when is_bitstring(user_document_id) do
    Documents.get_user_document_option_for_select(user_document_id)
  end

  defp user_document_value_mapper(value), do: value

  defp country_value_mapper(country_code) when is_bitstring(country_code) do
    Country.country_option_for_select(country_code)
  end

  defp country_value_mapper(value), do: value
end
