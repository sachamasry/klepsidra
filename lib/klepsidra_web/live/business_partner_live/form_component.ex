defmodule KlepsidraWeb.BusinessPartnerLive.FormComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component

  alias Klepsidra.BusinessPartners

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage business_partner records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="business_partner-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:customer]} type="checkbox" label="Customer" />
        <.input field={@form[:supplier]} type="checkbox" label="Supplier" />
        <.input field={@form[:active]} type="checkbox" label="Active" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Business partner</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{business_partner: business_partner} = assigns, socket) do
    changeset = BusinessPartners.change_business_partner(business_partner)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"business_partner" => business_partner_params}, socket) do
    changeset =
      socket.assigns.business_partner
      |> BusinessPartners.change_business_partner(business_partner_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"business_partner" => business_partner_params}, socket) do
    save_business_partner(socket, socket.assigns.action, business_partner_params)
  end

  defp save_business_partner(socket, :edit, business_partner_params) do
    case BusinessPartners.update_business_partner(
           socket.assigns.business_partner,
           business_partner_params
         ) do
      {:ok, business_partner} ->
        notify_parent({:saved, business_partner})

        {:noreply,
         socket
         |> put_flash(:info, "Business partner updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_business_partner(socket, :new, business_partner_params) do
    case BusinessPartners.create_business_partner(business_partner_params) do
      {:ok, business_partner} ->
        notify_parent({:saved, business_partner})

        {:noreply,
         socket
         |> put_flash(:info, "Business partner created successfully")
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
