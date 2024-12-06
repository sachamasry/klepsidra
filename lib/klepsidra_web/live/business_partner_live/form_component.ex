defmodule KlepsidraWeb.BusinessPartnerLive.FormComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component

  import LiveToast

  alias Klepsidra.BusinessPartners

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="business_partner-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <:actions>
          <.button phx-disable-with="Saving...">Save</.button>
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
    business_partner_params = Map.merge(business_partner_params, %{"customer" => "true"})

    save_business_partner(socket, socket.assigns.action, business_partner_params)
  end

  defp save_business_partner(socket, :edit, business_partner_params) do
    business_partner_type =
      if socket.assigns.business_partner_type == :customer, do: "Customer", else: "Supplier"

    case BusinessPartners.update_business_partner(
           socket.assigns.business_partner,
           business_partner_params
         ) do
      {:ok, business_partner} ->
        notify_parent({:saved, business_partner})

        {:noreply,
         socket
         |> put_toast(:info, "#{business_partner_type} updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_business_partner(socket, :new, business_partner_params) do
    business_partner_type =
      if socket.assigns.business_partner_type == :customer, do: "Customer", else: "Supplier"

    case BusinessPartners.create_business_partner(business_partner_params) do
      {:ok, business_partner} ->
        notify_parent({:saved, business_partner})

        {:noreply,
         socket
         |> put_toast(:info, "#{business_partner_type} created successfully")
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
