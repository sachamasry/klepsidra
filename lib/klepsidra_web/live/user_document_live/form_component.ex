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
        <.input field={@form[:name]} type="text" label="Name for the document" />

        <.live_select
          field={@form[:user_id]}
          mode={:single}
          label="User"
          allow_clear
          options={[]}
          placeholder="Which user's document is this?"
          debounce={200}
          dropdown_extra_class="bg-white max-h-48 overflow-y-scroll"
          update_min_len={2}
          value_mapper={&user_value_mapper/1}
          phx-target={@myself}
        >
          <:option :let={option}>
            <div class="flex">
              <%= option.label %>
            </div>
          </:option>
        </.live_select>

        <.live_select
          field={@form[:document_type_id]}
          mode={:single}
          label="Document type"
          allow_clear
          options={[]}
          placeholder="Type of document, e.g. passport, visa, driving license, etc."
          debounce={200}
          dropdown_extra_class="bg-white max-h-48 overflow-y-scroll"
          update_min_len={2}
          value_mapper={&document_type_value_mapper/1}
          phx-target={@myself}
        >
          <:option :let={option}>
            <div class="flex">
              <%= option.label %>
            </div>
          </:option>
        </.live_select>

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
        <.input field={@form[:issued_at]} type="date" label="Issue date" />
        <.input field={@form[:expires_at]} type="date" label="Expiry date" />

        <.input
          field={@form[:description]}
          type="textarea"
          label="Description"
          placeholder="Additional details or context"
        />

        <div :if={@action == :edit}>
          <.input field={@form[:is_active]} type="checkbox" label="Is this document still valid?" />
          <.input
            :if={@is_active? == false}
            field={@form[:invalidation_reason]}
            type="textarea"
            label="Invalidation reason"
            placeholder="Explanation for why the document is no longer valid"
          />
        </div>

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
    socket =
      socket
      |> assign(assigns)
      |> assign_new(:form, fn ->
        to_form(Documents.change_user_document(user_document))
      end)
      |> assign(is_active?: user_document.is_active)

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "live_select_change",
        %{
          "field" => "user_document_user_id",
          "id" => live_select_id,
          "text" => user_name_search_phrase
        },
        socket
      ) do
    users =
      Accounts.list_users_options_for_select_matching_name(user_name_search_phrase)

    send_update(LiveSelect.Component, id: live_select_id, options: users)
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "live_select_change",
        %{
          "field" => "user_document_document_type_id",
          "id" => live_select_id,
          "text" => document_type_search_phrase
        },
        socket
      ) do
    document_types =
      Documents.list_document_types_options_for_select_matching_name(document_type_search_phrase)

    send_update(LiveSelect.Component, id: live_select_id, options: document_types)
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "live_select_change",
        %{
          "field" => "user_document_document_issuer_id",
          "id" => live_select_id,
          "text" => document_issuer_search_phrase
        },
        socket
      ) do
    document_issuers =
      Documents.list_document_issuers_options_for_select_matching_name_with_country(
        document_issuer_search_phrase
      )

    send_update(LiveSelect.Component, id: live_select_id, options: document_issuers)
    {:noreply, socket}
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
        "validate",
        %{
          "_target" => ["user_document", "is_active"],
          "user_document" => %{"is_active" => is_active} = user_document_params
        },
        socket
      ) do
    changeset = Documents.change_user_document(socket.assigns.user_document, user_document_params)

    is_active? = is_active == "true" || is_active == "on" || false

    socket =
      socket
      |> assign(
        is_active?: is_active?,
        form: to_form(changeset, action: :validate)
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "validate",
        %{
          "_target" => ["user_document", "document_issuer_id"],
          "user_document" => %{"document_issuer_id" => ""}
        },
        socket
      ),
      do: {:noreply, socket}

  @impl true
  def handle_event(
        "validate",
        %{
          "_target" => ["user_document", "document_issuer_id"],
          "user_document" => %{"document_issuer_id" => document_issuer_id} = user_document_params
        },
        socket
      ) do
    document_issuer_country_id =
      Documents.get_document_issuer_with_country!(document_issuer_id).country_id

    user_document_params =
      user_document_params
      |> Map.merge(%{"country_id" => document_issuer_country_id})

    changeset =
      Documents.change_user_document(socket.assigns.user_document, user_document_params)

    socket =
      socket
      |> assign(form: to_form(changeset, action: :validate))

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

  defp user_value_mapper(user_id)
       when is_bitstring(user_id) do
    Accounts.get_user_option_for_select(user_id)
  end

  defp user_value_mapper(value), do: value

  defp document_type_value_mapper(document_type_id)
       when is_bitstring(document_type_id) do
    Documents.get_document_type_option_for_select(document_type_id)
  end

  defp document_type_value_mapper(value), do: value

  defp document_issuer_value_mapper(document_issuer_id)
       when is_bitstring(document_issuer_id) do
    Documents.get_document_issuer_option_for_select_with_country(document_issuer_id)
  end

  defp document_issuer_value_mapper(value), do: value

  defp country_value_mapper(country_code) when is_bitstring(country_code) do
    Country.country_option_for_select(country_code)
  end

  defp country_value_mapper(value), do: value
end
