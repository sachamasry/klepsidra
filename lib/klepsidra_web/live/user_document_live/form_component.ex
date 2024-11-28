defmodule KlepsidraWeb.UserDocumentLive.FormComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component
  import LiveToast

  alias Klepsidra.Documents
  alias Klepsidra.Accounts
  alias Klepsidra.Locations
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
        id="user_document-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          :if={false}
          field={@form[:user_id]}
          type="select"
          label="User"
          options={{"", ""}}
          selected=""
        />
        <.input field={@form[:document_type_id]} type="text" label="Document type" />

        <.live_select
          field={@form[:document_issuer_id]}
          mode={:single}
          label="Document issuer"
          allow_clear
          options={[]}
          placeholder="Document issuing body"
          debounce={200}
          dropdown_extra_class="bg-white max-h-48 overflow-y-scroll"
          update_min_len={2}
          value_mapper={&document_issuer_value_mapper/1}
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
          label="Issuing country"
          allow_clear
          options={[]}
          placeholder="Document issuing country"
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

        <.input field={@form[:unique_reference_number]} type="text" label="Unique reference number" />
        <.input field={@form[:name]} type="text" label="Name for the document" />
        <.input
          field={@form[:description]}
          type="textarea"
          label="Description"
          placeholder="Additional details or context"
        />
        <.input field={@form[:issued_at]} type="date" label="Issue date" />
        <.input field={@form[:expires_at]} type="date" label="Expiry date" />
        <.input field={@form[:is_active]} type="checkbox" label="Is this document still valid?" />
        <.input
          field={@form[:invalidation_reason]}
          type="textarea"
          label="Invalidation reason"
          placeholder="Explanation for why the document is no longer valid"
        />
        <.input
          :if={false}
          field={@form[:file_url]}
          type="text"
          label="File URL"
          placeholder="URL or file path to the document file"
        />
        <.input
          :if={false}
          field={@form[:custom_buffer_time_days]}
          type="number"
          label="Lead time for user action (days)"
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save User document</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{user_document: user_document} = assigns, socket) do
    user_options = Accounts.list_users_for_html_select()

    socket =
      socket
      |> assign(assigns)
      |> assign_new(:form, fn ->
        to_form(Documents.change_user_document(user_document))
      end)
      |> assign(user_options: user_options)

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "live_select_change",
        %{
          "field" => "user_document_country_id",
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
  def handle_event(
        "live_select_change",
        %{
          "field" => "user_document_document_issuer_id",
          "id" => live_select_id,
          "text" => document_issuers_search_phrase
        },
        socket
      ) do
    document_issuers =
      Documents.list_document_issuers_options_for_select_matching_name_with_country(
        document_issuers_search_phrase
      )

    send_update(LiveSelect.Component, id: live_select_id, options: document_issuers)
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"user_document" => user_document_params}, socket) do
    changeset = Documents.change_user_document(socket.assigns.user_document, user_document_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"user_document" => user_document_params}, socket) do
    save_user_document(socket, socket.assigns.action, user_document_params)
  end

  defp save_user_document(socket, :edit, user_document_params) do
    case Documents.update_user_document(socket.assigns.user_document, user_document_params) do
      {:ok, user_document} ->
        notify_parent({:saved, user_document})

        {:noreply,
         socket
         |> put_toast(:info, "User document updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_user_document(socket, :new, user_document_params) do
    case Documents.create_user_document(user_document_params) do
      {:ok, user_document} ->
        notify_parent({:saved, user_document})

        {:noreply,
         socket
         |> put_toast(:info, "User document created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp document_issuer_value_mapper(document_issuer_code)
       when is_bitstring(document_issuer_code) do
    # Country.country_options_for_select(document_issuer_code)
    %{value: "", label: ""}
  end

  defp document_issuer_value_mapper(value), do: value

  defp country_value_mapper(country_code) when is_bitstring(country_code) do
    Country.country_option_for_select(country_code)
  end

  defp country_value_mapper(value), do: value
end
