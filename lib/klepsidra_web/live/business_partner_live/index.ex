defmodule KlepsidraWeb.BusinessPartnerLive.Index do
  @moduledoc false

  use KlepsidraWeb, :live_view

  alias Klepsidra.BusinessPartners
  alias Klepsidra.BusinessPartners.BusinessPartner

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :business_partners, BusinessPartners.list_business_partners())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Business partner")
    |> assign(:business_partner, BusinessPartners.get_business_partner!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Business partner")
    |> assign(:business_partner, %BusinessPartner{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Business partners")
    |> assign(:business_partner, nil)
  end

  @impl true
  def handle_info(
        {KlepsidraWeb.BusinessPartnerLive.FormComponent, {:saved, business_partner}},
        socket
      ) do
    {:noreply, stream_insert(socket, :business_partners, business_partner)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    business_partner = BusinessPartners.get_business_partner!(id)
    {:ok, _} = BusinessPartners.delete_business_partner(business_partner)

    {:noreply, stream_delete(socket, :business_partners, business_partner)}
  end
end
