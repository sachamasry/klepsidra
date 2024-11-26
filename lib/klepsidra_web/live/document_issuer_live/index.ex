defmodule KlepsidraWeb.DocumentIssuerLive.Index do
  @moduledoc false

  use KlepsidraWeb, :live_view

  alias Klepsidra.Documents
  alias Klepsidra.Documents.DocumentIssuer

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :document_issuers, Documents.list_document_issuers())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Document issuer")
    |> assign(:document_issuer, Documents.get_document_issuer!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Document issuer")
    |> assign(:document_issuer, %DocumentIssuer{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Document issuers")
    |> assign(:document_issuer, nil)
  end

  @impl true
  def handle_info(
        {KlepsidraWeb.DocumentIssuerLive.FormComponent, {:saved, document_issuer}},
        socket
      ) do
    {:noreply, stream_insert(socket, :document_issuers, document_issuer)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    document_issuer = Documents.get_document_issuer!(id)
    {:ok, _} = Documents.delete_document_issuer(document_issuer)

    {:noreply, stream_delete(socket, :document_issuers, document_issuer)}
  end
end
