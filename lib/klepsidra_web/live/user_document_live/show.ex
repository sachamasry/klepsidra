defmodule KlepsidraWeb.UserDocumentLive.Show do
  @moduledoc false

  use KlepsidraWeb, :live_view

  alias Klepsidra.Documents
  alias Klepsidra.Accounts
  alias Klepsidra.Locations.Country

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    document = Documents.get_user_document!(id)

    user_name = Accounts.get_user_option_for_select(document.user_id)
    document_type = Documents.get_document_type_option_for_select(document.document_type_id)

    document_issuer =
      Documents.get_document_issuer_option_for_select_with_country(document.document_issuer_id)

    country_name = Country.country_option_for_select(document.country_id)

    socket =
      socket
      |> assign(
        page_title: page_title(socket.assigns.live_action),
        user_document: document,
        user_name: user_name.label,
        document_type: document_type.label,
        document_issuer: document_issuer.label,
        issuing_country_name: country_name.label
      )

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show user document"
  defp page_title(:edit), do: "Edit user document"
end
