defmodule KlepsidraWeb.TripLive.FormComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component

  alias Klepsidra.Travel

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage trip records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="trip-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:id]} type="text" label="Id" />
        <.input field={@form[:user_id]} type="text" label="User" />
        <.input field={@form[:country_id]} type="text" label="Country" />
        <.input field={@form[:entry_date]} type="date" label="Entry date" />
        <.input field={@form[:exit_date]} type="date" label="Exit date" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Trip</.button>
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
        notify_parent({:saved, trip})

        {:noreply,
         socket
         |> put_flash(:info, "Trip updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_trip(socket, :new, trip_params) do
    case Travel.create_trip(trip_params) do
      {:ok, trip} ->
        notify_parent({:saved, trip})

        {:noreply,
         socket
         |> put_flash(:info, "Trip created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
