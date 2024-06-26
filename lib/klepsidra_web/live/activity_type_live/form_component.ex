defmodule KlepsidraWeb.ActivityTypeLive.FormComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component

  alias Klepsidra.TimeTracking

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage activity_type records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="activity_type-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:activity_type]} type="text" label="Activity type" />
        <.input field={@form[:billing_rate]} type="number" label="Billing rate" step="any" />
        <.input field={@form[:active]} type="checkbox" label="Active" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Activity type</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{activity_type: activity_type} = assigns, socket) do
    changeset = TimeTracking.change_activity_type(activity_type)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"activity_type" => activity_type_params}, socket) do
    changeset =
      socket.assigns.activity_type
      |> TimeTracking.change_activity_type(activity_type_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"activity_type" => activity_type_params}, socket) do
    save_activity_type(socket, socket.assigns.action, activity_type_params)
  end

  defp save_activity_type(socket, :edit, activity_type_params) do
    case TimeTracking.update_activity_type(socket.assigns.activity_type, activity_type_params) do
      {:ok, activity_type} ->
        notify_parent({:saved, activity_type})

        {:noreply,
         socket
         |> put_flash(:info, "Activity type updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_activity_type(socket, :new, activity_type_params) do
    case TimeTracking.create_activity_type(activity_type_params) do
      {:ok, activity_type} ->
        notify_parent({:saved, activity_type})

        {:noreply,
         socket
         |> put_flash(:info, "Activity type created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
