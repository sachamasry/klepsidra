defmodule KlepsidraWeb.TimerLive.AutomatedTimer do
  @moduledoc false

  use KlepsidraWeb, :live_component

  alias Klepsidra.TimeTracking
  alias Klepsidra.TimeTracking.Timer
  alias Klepsidra.TimeTracking.TimeUnits, as: Units
  alias Klepsidra.Projects.Project
  alias Klepsidra.BusinessPartners.BusinessPartner

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
          <.input field={@form[:start_stamp]} type="datetime-local" label="Start time" readonly />

          <.input field={@form[:end_stamp]} type="datetime-local" label="End time" readonly />

          <.input field={@form[:duration]} type="text" label="Duration" readonly />

          <.input
            field={@form[:duration_time_unit]}
            type="select"
            label="Duration time increment"
            options={Units.construct_duration_unit_options_list(use_primitives?: true)}
          />

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
        nil -> timer
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

    {:ok,
     socket
     |> assign_form(changeset)
     |> assign(billable_activity?: assigns.timer.billable)
     |> assign_business_partner()
     |> assign_project()
     |> assign(assigns)}
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

  @spec assign_project(Phoenix.LiveView.Socket.t()) :: Klepsidra.Projects.Project.t()
  defp assign_project(socket) do
    projects = Project.populate_projects_list()

    assign(socket, projects: projects)
  end

  # @spec assign_business_partner(Phoenix.LiveView.Socket.t()) ::
  #         Klepsidra.BusinessPartners.BusinessPartner.t()
  defp assign_business_partner(socket) do
    business_partners = BusinessPartner.populate_customers_list()

    assign(socket, business_partners: business_partners)
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
