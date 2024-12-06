defmodule KlepsidraWeb.BusinessPartnerLive.Show do
  @moduledoc false

  use KlepsidraWeb, :live_view

  import KlepsidraWeb.ButtonComponents

  alias Klepsidra.BusinessPartners

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :business_partner_type, :customer)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:business_partner, BusinessPartners.get_business_partner!(id))}
  end

  defp page_title(:show), do: "Show customer"
  defp page_title(:edit), do: "Edit customer"
end
