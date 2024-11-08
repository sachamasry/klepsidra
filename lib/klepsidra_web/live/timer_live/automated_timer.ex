defmodule KlepsidraWeb.TimerLive.AutomatedTimer do
  @moduledoc false

  use KlepsidraWeb, :live_component

  alias Klepsidra.TimeTracking
  alias Klepsidra.TimeTracking.Timer
  alias Klepsidra.TimeTracking.TimeUnits, as: Units
  alias Klepsidra.Projects.Project
  alias Klepsidra.BusinessPartners.BusinessPartner
  # alias Klepsidra.TimeTracking.ActivityType
  alias Klepsidra.Categorisation
  alias Klepsidra.Categorisation.Tag
  alias KlepsidraWeb.TagLive.TagUtilities
  alias Klepsidra.DynamicCSS

  @tag_search_live_component_id "timer_ls_tag_search_live_select_component"

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="timer-form"
        phx-target={@myself}
        phx-change="validate"
        phx-window-keyup="key_up"
        phx-submit="save"
      >
        <div :if={@invocation_context == :start_timer}>
          <.input
            field={@form[:description]}
            type="text"
            label="Description"
            placeholder="What are you working on?"
            autocomplete="off"
          />
        </div>

        <div :if={@invocation_context == :stop_timer}>
          <div class="hidden">
            <.input field={@form[:start_stamp]} type="datetime-local" label="Start time" readonly />

            <.input field={@form[:end_stamp]} type="datetime-local" label="End time" readonly />
          </div>

          <.input field={@form[:duration]} type="text" label="Duration" readonly />

          <.input
            field={@form[:duration_time_unit]}
            type="select"
            label="Duration time increment"
            options={Units.construct_duration_unit_options_list(use_primitives?: true)}
          />
        </div>

        <div id="tag-selector" class={"flex #{if @selected_tag_queue != [], do: "gap-2"}"}>
          <div
            id="tag-selector__live-select"
            phx-mounted={JS.add_class("hidden", to: "#timer_ls_tag_search_text_input")}
          >
            <.live_select
              field={@form[:ls_tag_search]}
              mode={:tags}
              label=""
              options={[]}
              placeholder="Add tag"
              debounce={80}
              clear_tag_button_class="cursor-pointer px-1 rounded-r-md"
              dropdown_extra_class="bg-white max-h-48 overflow-y-scroll"
              tag_class="bg-slate-400 text-white flex rounded-md text-sm font-semibold"
              tags_container_class="flex flex-wrap gap-2"
              container_extra_class="rounded border border-none"
              update_min_len={1}
              user_defined_options="true"
              value={@selected_tags}
              phx-blur="ls_tag_search_blur"
              phx-target={@myself}
            >
              <:option :let={option}>
                <div class="flex" title={option.description}>
                  <%= option.label %>
                </div>
              </:option>
              <:tag :let={option}>
                <div class={"#{option.tag_class} py-1.5 px-3 rounded-l-md"} title={option.description}>
                  <.link navigate={~p"/tags/#{option.value}"}>
                    <%= option.label %>
                  </.link>
                </div>
              </:tag>
            </.live_select>
          </div>

          <div
            id="tag-selector__colour-select"
            class="tag-colour-picker hidden w-10 overflow-hidden self-end shrink-0"
          >
            <.input field={@form[:bg_colour]} type="color" value={elem(@new_tag_colour, 0)} />
          </div>

          <.button
            id="tag-selector__add-button"
            class="flex-none flex-grow-0 h-fit self-end [&&]:bg-violet-50 [&&]:text-indigo-900 [&&]:py-1 rounded-md"
            type="button"
            phx-click={enable_tag_selector()}
          >
            Add tag +
          </.button>
        </div>

        <div :if={@invocation_context == :stop_timer}>
          <.input
            field={@form[:description]}
            type="textarea"
            label="Description"
            placeholder="What did you work on?"
          />
        </div>

        <.input field={@form[:project_id]} type="select" label="Project" options={@projects} />

        <.input
          field={@form[:business_partner_id]}
          type="select"
          label="Customer"
          placeholder="Customer"
          options={@business_partners}
          required={@billable_activity?}
        />

        <.input field={@form[:billable]} type="checkbox" label="Billable?" />

        <div class={unless @billable_activity? && @invocation_context == :stop_timer, do: "hidden"}>
          <.input field={@form[:billing_duration]} type="text" label="Billable duration" readonly />

          <.input
            field={@form[:billing_duration_time_unit]}
            type="select"
            label="Billable time increment"
            options={Units.construct_duration_unit_options_list()}
          />
        </div>

        <:actions>
          <.button phx-disable-with="Saving...">
            <%= if @invocation_context == :start_timer, do: "Start timer", else: "Save" %>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  @spec update(map(), Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def update(%{timer: timer} = assigns, socket) do
    timer =
      case timer.id do
        nil -> timer |> Klepsidra.Repo.preload(:tags)
        _ -> TimeTracking.get_timer!(timer.id) |> Klepsidra.Repo.preload(:tags)
      end

    timer_changes =
      case assigns.invocation_context do
        :stop_timer ->
          start_stamp = timer.start_stamp
          end_stamp = Timer.get_current_timestamp() |> Timer.convert_naivedatetime_to_html!()
          duration_time_unit = timer.duration_time_unit
          billing_duration_time_unit = timer.billing_duration_time_unit

          duration =
            Timer.assign_timer_duration(
              %{
                "start_stamp" => start_stamp,
                "end_stamp" => end_stamp,
                "duration_time_unit" => duration_time_unit
              },
              "duration_time_unit"
            )

          billable = Timer.read_checkbox(timer.billable)

          billing_duration =
            if billable do
              Timer.assign_timer_duration(
                %{
                  "start_stamp" => start_stamp,
                  "end_stamp" => end_stamp,
                  "billing_duration_time_unit" => billing_duration_time_unit
                },
                "billing_duration_time_unit"
              )
            else
              0
            end

          %{
            "end_stamp" => end_stamp,
            "duration" => duration,
            "billing_duration" => billing_duration
          }

        _ ->
          %{}
      end

    changeset = TimeTracking.change_timer(timer, timer_changes)

    socket =
      socket
      |> TagUtilities.generate_tag_options(
        [],
        Enum.map(timer.tags, fn tag -> tag.id end),
        @tag_search_live_component_id
      )
      |> Phx.Live.Head.push(
        "style[id*=dynamic-style-block]",
        :dynamic,
        "style_declarations",
        DynamicCSS.generate_tag_styles(timer.tags)
      )

    socket =
      socket
      |> assign_form(changeset)
      |> assign(
        billable_activity?: assigns.timer.billable,
        new_tag_colour: {"#94a3b8", "#fff"}
      )
      |> assign_business_partner()
      |> assign_project()
      |> assign(assigns)

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "validate",
        %{"_target" => ["timer", "duration_time_unit"], "timer" => timer_params},
        socket
      ) do
    changeset =
      socket.assigns.timer
      |> TimeTracking.change_timer(%{
        timer_params
        | "duration" => Timer.assign_timer_duration(timer_params, "duration_time_unit")
      })
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"_target" => ["timer", "billing_duration_time_unit"], "timer" => timer_params},
        socket
      ) do
    billable = Timer.read_checkbox(timer_params["billable"])

    billing_duration =
      if billable do
        Timer.assign_timer_duration(timer_params, "billing_duration_time_unit")
      else
        0
      end

    changeset =
      socket.assigns.timer
      |> TimeTracking.change_timer(%{
        timer_params
        | "billing_duration" => billing_duration
      })
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"_target" => ["timer", "billable"], "timer" => timer_params},
        socket
      ) do
    billable = Timer.read_checkbox(timer_params["billable"])

    billing_duration =
      if billable do
        Timer.assign_timer_duration(timer_params, "billing_duration_time_unit")
      else
        0
      end

    changeset =
      socket.assigns.timer
      |> TimeTracking.change_timer(%{
        timer_params
        | "billing_duration" => billing_duration
      })
      |> Map.put(:action, :validate)

    socket =
      socket
      |> assign(billable_activity?: billable)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event(
        "validate",
        %{"_target" => ["timer", "ls_tag_search"], "timer" => %{"ls_tag_search" => tags_applied}},
        socket
      ) do
    Tag.handle_tag_list_changes(
      socket.assigns.selected_tag_queue,
      tags_applied,
      socket.assigns.timer.id
    )

    socket =
      TagUtilities.generate_tag_options(
        socket,
        socket.assigns.selected_tag_queue,
        tags_applied,
        @tag_search_live_component_id
      )
      |> Phx.Live.Head.push(
        "style[id*=dynamic-style-block]",
        :dynamic,
        "style_declarations",
        DynamicCSS.generate_tag_styles(tags_applied)
      )

    socket =
      socket
      |> assign(
        tag_search_phrase: nil,
        possible_free_tag_entered: false
      )

    {:noreply, socket}
  end

  @doc """
  Validate event which fires only once the last of the tags has been cleared
  from a `live_select` component.
  """
  def handle_event(
        "validate",
        %{
          "_target" => ["timer", "ls_tag_search_empty_selection"],
          "timer" => %{"ls_tag_search_empty_selection" => ""}
        },
        socket
      ) do
    Tag.handle_tag_list_changes(socket.assigns.selected_tag_queue, [], socket.assigns.timer.id)

    socket =
      socket
      |> assign(
        tag_search_phrase: nil,
        possible_free_tag_entered: false
      )

    {:noreply, socket}
  end

  def handle_event(
        "validate",
        %{
          "_target" => ["timer", "bg_colour"],
          "timer" => %{
            "bg_colour" => bg_colour
          }
        },
        socket
      ) do
    fg_colour =
      case ColorContrast.calc_contrast(bg_colour) do
        {:ok, fg_colour} -> fg_colour
        {:error, _} -> "#fff"
      end

    socket =
      socket
      |> assign(new_tag_colour: {bg_colour, fg_colour})

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"timer" => timer_params}, socket) do
    changeset =
      socket.assigns.timer
      |> TimeTracking.change_timer(timer_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"timer" => timer_params}, socket) do
    save_timer(socket, socket.assigns.action, timer_params)
  end

  def handle_event(
        "live_select_change",
        %{
          "field" => "timer_ls_tag_search",
          "id" => live_select_id,
          "text" => tag_search_phrase
        },
        socket
      ) do
    tag_search_results =
      Categorisation.search_tags_by_name_content(tag_search_phrase)
      |> TagUtilities.tag_options_for_live_select()

    send_update(LiveSelect.Component, id: live_select_id, options: tag_search_results)

    socket =
      socket
      |> assign(
        tag_search_phrase: tag_search_phrase,
        possible_free_tag_entered: true
      )

    {:noreply, socket}
  end

  def handle_event(
        "ls_tag_search_blur",
        %{"id" => @tag_search_live_component_id},
        socket
      ) do
    socket =
      socket
      |> assign(
        tag_search_phrase: nil,
        possible_free_tag_entered: false
      )

    {:noreply, socket}
  end

  def handle_event(
        "key_up",
        %{"key" => "Enter"},
        %{assigns: %{tag_search_phrase: tag_search_phrase, possible_free_tag_entered: true}} =
          socket
      ) do
    socket =
      TagUtilities.handle_free_tagging(
        socket,
        tag_search_phrase,
        String.length(tag_search_phrase),
        @tag_search_live_component_id,
        socket.assigns.new_tag_colour
      )

    {:noreply, socket}
  end

  def handle_event("key_up", %{"key" => _}, socket), do: {:noreply, socket}

  defp save_timer(socket, :start_timer, timer_params) do
    timer_params =
      Map.merge(timer_params, %{
        "start_stamp" =>
          Timer.get_current_timestamp()
          |> Timer.convert_naivedatetime_to_html!(),
        "duration" => "0",
        "duration_time_unit" => "minute",
        "billing_duration" => "0",
        "billing_duration_time_unit" => Units.get_default_billing_increment()
      })

    case TimeTracking.create_timer(timer_params) do
      {:ok, timer} ->
        timer = TimeTracking.get_formatted_timer_record!(timer.id)

        Tag.handle_tag_list_changes([], socket.assigns.selected_tag_queue, timer.id)

        notify_parent({:timer_started, timer})

        {:noreply,
         socket
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_timer(socket, :stop_timer, timer_params) do
    case TimeTracking.update_timer(socket.assigns.timer, timer_params) do
      {:ok, timer} ->
        timer = TimeTracking.get_formatted_timer_record!(timer.id)
        notify_parent({:timer_stopped, timer})

        {:noreply,
         socket
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  @spec assign_project(Phoenix.LiveView.Socket.t()) ::
          Phoenix.LiveView.Socket.t()
  defp assign_project(socket) do
    projects = Project.populate_projects_list()

    assign(socket, projects: projects)
  end

  @spec assign_business_partner(Phoenix.LiveView.Socket.t()) ::
          Phoenix.LiveView.Socket.t()
  defp assign_business_partner(socket) do
    business_partners = BusinessPartner.populate_customers_list()

    assign(socket, business_partners: business_partners)
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp enable_tag_selector() do
    JS.remove_class("hidden", to: "#timer_ls_tag_search_text_input")
    |> JS.remove_class("hidden", to: "#tag-selector__colour-select")
    |> JS.add_class("hidden", to: "#tag-selector__add-button")
    |> JS.add_class("gap-2", to: "#tag-selector")
    |> JS.add_class("flex-auto", to: "#tag-selector__live-select")
    |> JS.focus(to: "#timer_ls_tag_search_text_input")
  end
end
