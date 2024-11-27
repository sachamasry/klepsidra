defmodule KlepsidraWeb.DocumentIssuerLive.Show do
  @moduledoc false

  use KlepsidraWeb, :live_view

  alias Klepsidra.Documents
  alias Klepsidra.Locations.Country

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    document_issuer = Documents.get_document_issuer!(id)

    country_name = Country.country_options_for_select(document_issuer.country_id)

    socket =
      socket
      |> assign(
        page_title: page_title(socket.assigns.live_action),
        document_issuer: Documents.get_document_issuer!(id),
        issuing_country_name: country_name.label
      )

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Document issuer"
  defp page_title(:edit), do: "Edit Document issuer"
end
