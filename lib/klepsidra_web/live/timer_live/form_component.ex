defmodule KlepsidraWeb.TimerLive.FormComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component

  alias Klepsidra.TimeTracking
  alias Klepsidra.TimeTracking.Timer
  alias Klepsidra.TimeTracking.TimeUnits, as: Units
  alias Klepsidra.Projects.Project
  alias Klepsidra.BusinessPartners.BusinessPartner
  alias Klepsidra.TimeTracking.ActivityType

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Manage activity timers.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="timer-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:start_stamp]} type="datetime-local" label="Start time" />
        <.input field={@form[:end_stamp]} type="datetime-local" label="End time" />

        <.input field={@form[:duration]} type="text" label="Duration" readonly />

        <.input
          field={@form[:duration_time_unit]}
          type="select"
          label="Duration time increment"
          options={Units.construct_duration_unit_options_list(use_primitives?: true)}
        />

        <.input field={@form[:description]} type="textarea" label="Description" />

        <.input field={@form[:project_id]} type="select" label="Project" options={@projects} />

        <.input
          field={@form[:business_partner_id]}
          type="select"
          label="Customer"
          options={@business_partners}
          required={@billable_activity?}
        />

        <.input field={@form[:billable]} type="checkbox" label="Billable?" />

        <div class={unless @billable_activity?, do: "hidden"}>
          <.input field={@form[:billing_duration]} type="text" label="Billable duration" readonly />

          <.input
            field={@form[:billing_duration_time_unit]}
            type="select"
            label="Billable time increment"
            options={Units.construct_duration_unit_options_list()}
          />

          <.input
            field={@form[:activity_type_id]}
            type="select"
            label="Activity type"
            options={@activity_types}
          />

          <.input
            field={@form[:billing_rate]}
            type="number"
            label="Hourly billing rate"
            min="0"
            step="0.01"
          />
        </div>

        <:actions>
          <.button phx-disable-with="Saving...">Save</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  @spec update(map(), Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def update(%{timer: timer} = assigns, socket) do
    timer_changes =
      case assigns.invocation_context do
        :new_timer ->
          %{
            "duration" => "0",
            "duration_time_unit" => "minute",
            "billing_duration" => "0",
            "billing_duration_time_unit" => Units.get_default_billing_increment()
          }

        _ ->
          %{}
      end

    changeset = TimeTracking.change_timer(timer, timer_changes)

    socket =
      socket
      |> assign(assigns)
      |> assign(billable_activity?: assigns.timer.billable)
      |> assign_project()
      |> assign_business_partner()
      |> assign_activity_type()
      |> assign_form(changeset)

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "validate",
        %{"_target" => ["timer", "start_stamp"], "timer" => timer_params},
        socket
      ) do
    duration = Timer.assign_timer_duration(timer_params, "duration_time_unit")
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
        | "duration" => duration,
          "billing_duration" => billing_duration
      })
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event(
        "validate",
        %{"_target" => ["timer", "end_stamp"], "timer" => timer_params},
        socket
      ) do
    duration = Timer.assign_timer_duration(timer_params, "duration_time_unit")

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
        | "duration" => duration,
          "billing_duration" => billing_duration
      })
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

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

    activity_type_id =
      case billable do
        true -> socket.assigns.timer.activity_type_id
        false -> ""
      end

    changeset =
      socket.assigns.timer
      |> TimeTracking.change_timer(%{
        timer_params
        | "activity_type_id" => activity_type_id,
          "billing_duration" => billing_duration
      })
      |> Map.put(:action, :validate)

    socket =
      socket
      |> assign(billable_activity?: billable)
      |> assign_activity_type()

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event(
        "validate",
        %{"_target" => ["timer", "activity_type_id"], "timer" => timer_params},
        socket
      ) do
    billable = Timer.read_checkbox(timer_params["billable"])

    billing_rate =
      if billable do
        activity_type_id = timer_params["activity_type_id"]

        Klepsidra.TimeTracking.get_activity_type!(activity_type_id).billing_rate
      else
        0
      end

    changeset =
      socket.assigns.timer
      |> TimeTracking.change_timer(%{
        timer_params
        | "billing_rate" => billing_rate
      })
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

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

  defp save_timer(socket, :new_timer, timer_params) do
    case TimeTracking.create_timer(timer_params) do
      {:ok, timer} ->
        timer = TimeTracking.get_formatted_timer_record!(timer.id)

        if timer.start_stamp != "" && timer.end_stamp != "" && not is_nil(timer.end_stamp) do
          notify_parent({:saved_closed_timer, timer})
        else
          notify_parent({:saved_open_timer, timer})
        end

        {:noreply,
         socket
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_timer(socket, :edit_timer, timer_params) do
    case TimeTracking.update_timer(socket.assigns.timer, timer_params) do
      {:ok, timer} ->
        timer = TimeTracking.get_formatted_timer_record!(timer.id)

        if timer.start_stamp != "" && timer.end_stamp != "" && not is_nil(timer.end_stamp) do
          notify_parent({:updated_closed_timer, timer})
        else
          notify_parent({:updated_open_timer, timer})
        end

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

  # @spec assign_project(Phoenix.LiveView.Socket.t()) :: [Klepsidra.Projects.Project.t(), ...]
  defp assign_project(socket) do
    projects = Project.populate_projects_list()

    assign(socket, projects: projects)
  end

  # @spec assign_business_partner(Phoenix.LiveView.Socket.t()) :: [Klepsidra.Projects.Project.t(), ...]
  defp assign_business_partner(socket) do
    business_partners = BusinessPartner.populate_customers_list()

    assign(socket, business_partners: business_partners)
  end

  defp assign_activity_type(socket) do
    activity_types =
      case socket.assigns.billable_activity? do
        true ->
          ActivityType.populate_activity_types_list()

        _ ->
          [{"", ""}]
      end

    assign(socket, activity_types: activity_types)
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
