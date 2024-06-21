defmodule KlepsidraWeb.TimerLive.FormComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component

  alias Klepsidra.TimeTracking
  alias Klepsidra.TimeTracking.Timer
  alias Klepsidra.TimeTracking.TimeUnits, as: Units
  alias Klepsidra.Projects
  alias Klepsidra.BusinessPartners

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

        <div :if={@invocation_context == :new_timer}>
          <.input
            field={@form[:duration]}
            type="text"
            label="Duration"
            value={@duration || 0}
            readonly
          />

          <.input
            field={@form[:duration_time_unit]}
            type="select"
            label="Duration time increment"
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
            type="select"
            label="Billable time increment"
            options={Units.construct_duration_unit_options_list()}
            value={Units.get_default_billing_increment()}
          />
        </div>

        <div :if={@invocation_context == :edit_timer}>
          <.input field={@form[:duration]} type="text" label="Duration" readonly />

          <.input
            field={@form[:duration_time_unit]}
            type="select"
            label="Duration time increment"
            options={Units.construct_duration_unit_options_list(use_primitives?: true)}
          />

          <.input field={@form[:billing_duration]} type="text" label="Billable duration" readonly />

          <.input
            field={@form[:billing_duration_time_unit]}
            type="select"
            label="Billable time increment"
            options={Units.construct_duration_unit_options_list()}
          />
        </div>

        <.input field={@form[:description]} type="textarea" label="Description" />

        <.input
          field={@form[:billable]}
          type="checkbox"
          phx-click="toggle-billable"
          phx-target={@myself}
          label="Billable?"
        />

        <div class={if !@billable_activity?, do: "hidden"}>
          <.input
            field={@form[:business_partner_id]}
            type="select"
            required={@billable_activity?}
            label="Customer"
            options={@business_partners}
          />
        </div>

        <.input field={@form[:project_id]} type="select" label="Project" options={@projects} />

        <:actions>
          <.button phx-disable-with="Saving...">Save</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{timer: timer} = assigns, socket) do
    changeset = TimeTracking.change_timer(timer)

    socket =
      socket
      |> assign(assigns)
      |> assign(billable_activity?: assigns.timer.billable)
      |> assign_business_partner()
      |> assign_project()
      |> assign_form(changeset)

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "validate",
        %{"_target" => ["timer", "start_stamp"], "timer" => timer_params},
        socket
      ) do
    changeset =
      socket.assigns.timer
      |> TimeTracking.change_timer(%{
        timer_params
        | "duration" => assign_timer_duration(timer_params, "duration_time_unit"),
          "billing_duration" => assign_timer_duration(timer_params, "billing_duration_time_unit")
      })
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event(
        "validate",
        %{"_target" => ["timer", "end_stamp"], "timer" => timer_params},
        socket
      ) do
    changeset =
      socket.assigns.timer
      |> TimeTracking.change_timer(%{
        timer_params
        | "duration" => assign_timer_duration(timer_params, "duration_time_unit"),
          "billing_duration" => assign_timer_duration(timer_params, "billing_duration_time_unit")
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
        | "duration" => assign_timer_duration(timer_params, "duration_time_unit")
      })
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event(
        "validate",
        %{"_target" => ["timer", "billing_duration_time_unit"], "timer" => timer_params},
        socket
      ) do
    changeset =
      socket.assigns.timer
      |> TimeTracking.change_timer(%{
        timer_params
        | "billing_duration" => assign_timer_duration(timer_params, "billing_duration_time_unit")
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

  def handle_event("toggle-billable", _params, socket) do
    billable_activity = !socket.assigns.billable_activity?

    business_partner_id =
      case billable_activity do
        true -> socket.assigns.timer.business_partner_id
        false -> ""
      end

    changeset =
      socket.assigns.form.data
      |> TimeTracking.change_timer(%{
        billable: billable_activity,
        business_partner_id: business_partner_id
      })
      |> Map.put(:action, :update)

    socket =
      socket
      |> assign(billable_activity?: billable_activity)
      |> assign_business_partner()
      |> assign_form(changeset)

    {:noreply, socket}
  end

  def handle_event("save", %{"timer" => timer_params}, socket) do
    save_timer(socket, socket.assigns.action, timer_params)
  end

  defp save_timer(socket, :edit_timer, timer_params) do
    end_stamp = timer_params["end_stamp"]

    validated_end_stamp =
      case end_stamp do
        "" ->
          ""

        _ ->
          case Timer.parse_html_datetime(end_stamp) do
            {:ok, timestamp} -> Timer.convert_naivedatetime_to_html!(timestamp)
            _ -> ""
          end
      end

    # end_timer =
    #   Timer.parse_html_datetime!(timer_params["end_stamp"])
    #   |> Timer.convert_naivedatetime_to_html!()

    timer_params =
      Map.put(timer_params, "end_stamp", validated_end_stamp)

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

  defp save_timer(socket, :new_timer, timer_params) do
    case TimeTracking.create_timer(timer_params) do
      {:ok, timer} ->
        notify_parent({:saved, timer})

        {:noreply,
         socket
         |> put_flash(:info, "Timer created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  @spec assign_timer_duration(%{optional(any) => any}, String.t()) :: integer()
  def assign_timer_duration(timer_params, duration_field) do
    start_stamp = timer_params["start_stamp"]
    end_stamp = timer_params["end_stamp"]
    duration_time_unit = timer_params[duration_field]

    duration =
      with true <- start_stamp != "",
           true <- end_stamp != "",
           true <- duration_time_unit != "" do
        Timer.calculate_timer_duration(
          start_stamp,
          end_stamp,
          String.to_atom(duration_time_unit)
        )
      else
        _ -> 0
      end

    duration
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

  defp assign_business_partner(socket) do
    business_partners =
      case socket.assigns.billable_activity? do
        true ->
          [
            {"-- Select Customer --", ""}
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
