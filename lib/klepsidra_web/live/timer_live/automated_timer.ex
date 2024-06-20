defmodule KlepsidraWeb.TimerLive.AutomatedTimer do
  @moduledoc false

  use KlepsidraWeb, :live_component

  alias Klepsidra.TimeTracking
  alias Klepsidra.TimeTracking.Timer
  alias Klepsidra.TimeTracking.TimeUnits, as: Units
  # alias Klepsidra.Categorisation.TimerTags
  alias Klepsidra.Projects
  alias Klepsidra.BusinessPartners

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
        <div :if={@invocation_context == :start}>
          <.input
            field={@form[:description]}
            type="text"
            label="Description"
            placeholder="What are you working on?"
          />
        </div>

        <div :if={@invocation_context == :stop}>
          <.input field={@form[:start_stamp]} type="datetime-local" label="Start time" disabled />

          <.input
            field={@form[:end_stamp]}
            phx-change="end_stamp_change"
            type="datetime-local"
            label="End time"
            value={@timer.end_stamp || @end_timestamp}
          />

          <.input
            field={@form[:duration]}
            type="text"
            label="Duration"
            value={@duration || 0}
            readonly
          />

          <.input
            field={@form[:duration_time_unit]}
            phx-change="duration_unit_change"
            type="select"
            label="Duration time unit"
            options={Units.construct_duration_unit_options_list(use_primitives?: true)}
            value={@duration_unit}
          />

          <.input
            field={@form[:billing_duration]}
            type="text"
            label="Billable duration"
            value={@billing_duration || @duration || 0}
            readonly
          />
          <.input
            field={@form[:billing_duration_time_unit]}
            phx-change="billing_duration_unit_change"
            type="select"
            label="Billable duration time unit"
            options={Units.construct_duration_unit_options_list()}
            value={Units.get_default_billing_increment()}
          />

          <.input
            field={@form[:description]}
            type="textarea"
            label="Description"
            placeholder="What did you work on?"
          />
        </div>

        <.input
          field={@form[:billable]}
          type="checkbox"
          phx-click="toggle-billable"
          phx-target={@myself}
          label="Billable?"
        />

        <.input
          :if={@billable_activity?}
          field={@form[:business_partner_id]}
          type="select"
          label="Customer"
          placeholder="Customer"
          options={@business_partners}
        />

        <.input
          field={@form[:project_id]}
          type="select"
          label="Project"
          placeholder="Project"
          options={@projects}
        />

        <:actions>
          <.button :if={@invocation_context == :start} phx-disable-with="Saving...">Start</.button>
          <.button :if={@invocation_context == :stop} phx-disable-with="Saving...">Stop</.button>
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

    changeset = TimeTracking.change_timer(timer)

    {:ok,
     socket
     |> assign_form(changeset)
     |> assign(billable_activity?: false)
     |> assign_business_partner()
     |> assign_project()
     |> assign(assigns)}
  end

  @impl true
  def handle_event("validate", %{"timer" => timer_params}, socket) do
    changeset =
      socket.assigns.timer
      |> TimeTracking.change_timer(timer_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("duration_unit_change", params, socket) do
    %{"timer" => %{"duration_time_unit" => duration_time_unit}} = params

    start_timestamp =
      Map.get(socket.assigns.form.params, "start_stamp", nil) || socket.assigns.timer.start_stamp

    end_timestamp =
      Map.get(socket.assigns.form.params, "end_stamp", nil) || socket.assigns.end_timestamp

    duration =
      Timer.calculate_timer_duration(
        start_timestamp,
        end_timestamp,
        String.to_atom(duration_time_unit)
      )
      |> to_string()

    socket =
      assign(socket, duration: duration, duration_unit: duration_time_unit)

    {:noreply, socket}
  end

  def handle_event("billing_duration_unit_change", params, socket) do
    %{"timer" => %{"billing_duration_time_unit" => billing_duration_time_unit}} = params

    start_timestamp =
      Map.get(socket.assigns.form.params, "start_stamp", nil) || socket.assigns.timer.start_stamp

    end_timestamp =
      Map.get(socket.assigns.form.params, "end_stamp", nil) || socket.assigns.end_timestamp

    duration =
      Timer.calculate_timer_duration(
        start_timestamp,
        end_timestamp,
        String.to_atom(billing_duration_time_unit)
      )
      |> to_string()

    socket =
      assign(socket,
        billing_duration: duration,
        billing_duration_time_unit: billing_duration_time_unit
      )

    {:noreply, socket}
  end

  def handle_event("end_stamp_change", params, socket) do
    %{"timer" => %{"end_stamp" => end_timestamp}} = params

    start_timestamp =
      Map.get(socket.assigns.form.params, "start_stamp", nil) || socket.assigns.timer.start_stamp

    duration_time_unit = socket.assigns.duration_unit

    billing_duration_time_unit =
      Map.get(socket.assigns, :billing_duration_time_unit, nil) ||
        socket.assigns.billing_duration_unit

    duration =
      Timer.calculate_timer_duration(
        start_timestamp,
        end_timestamp,
        String.to_atom(duration_time_unit)
      )
      |> to_string()

    billing_duration =
      Timer.calculate_timer_duration(
        start_timestamp,
        end_timestamp,
        String.to_atom(billing_duration_time_unit)
      )
      |> to_string()

    {:noreply,
     assign(socket,
       end_stamp: end_timestamp,
       duration: duration,
       duration_time_unit: duration_time_unit,
       billing_duration: billing_duration,
       billing_duration_time_unit: billing_duration_time_unit
     )}
  end

  def handle_event("toggle-billable", _, socket) do
    billable_activity = !socket.assigns.billable_activity?

    socket =
      socket
      |> assign(billable_activity?: billable_activity)
      |> assign_business_partner()

    {:noreply, socket}
  end

  def handle_event("save", %{"timer" => timer_params}, socket) do
    save_timer(socket, socket.assigns.action, timer_params)
  end

  defp save_timer(socket, :stop, timer_params) do
    case TimeTracking.update_timer(socket.assigns.timer, timer_params) do
      {:ok, timer} ->
        notify_parent({:saved, timer})

        {:noreply,
         socket
         |> put_flash(:info, "Timer updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_timer(socket, :start, timer_params) do
    timer_params =
      Map.merge(timer_params, %{
        "start_stamp" =>
          Timer.get_current_timestamp()
          |> Timer.convert_naivedatetime_to_html!()
      })

    case TimeTracking.create_timer(timer_params) do
      {:ok, timer} ->
        notify_parent({:saved, timer})

        {:noreply,
         socket
         |> put_flash(:info, "Timer started successfully")
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
    projects =
      [
        {"", ""}
        | Projects.list_projects()
          |> Enum.map(fn project -> {project.name, project.id} end)
      ]

    assign(socket, projects: projects)
  end

  # @spec assign_business_partner(Phoenix.LiveView.Socket.t()) ::
  #         Klepsidra.BusinessPartners.BusinessPartner.t()
  defp assign_business_partner(socket) do
    business_partners =
      case socket.assigns.billable_activity? do
        true ->
          [
            {"", ""}
            | BusinessPartners.list_business_partners()
              |> Enum.map(fn bp -> {bp.name, bp.id} end)
          ]

        _ ->
          [{"", ""}]
      end

    assign(socket, business_partners: business_partners)
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
