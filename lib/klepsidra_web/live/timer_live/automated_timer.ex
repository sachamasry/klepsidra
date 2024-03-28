defmodule KlepsidraWeb.TimerLive.AutomatedTimer do
  use KlepsidraWeb, :live_component

  alias Klepsidra.TimeTracking
  alias Klepsidra.TimeTracking.TimeUnits, as: Units

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
        <.input field={@form[:start_stamp]} type="datetime-local" label="Start time"
          value={@timer.start_stamp || @start_timestamp} readonly
        />

        <div :if={@invocation_context == :stop}>
          <.input field={@form[:end_stamp]}
            phx-change="end_stamp_change"
            type="datetime-local" label="End time"
            value={@timer.end_stamp || @end_timestamp} />

          <.input field={@form[:duration]} type="text" label="Duration"
            value={@duration || 0} readonly
          />

          <.input field={@form[:duration_time_unit]}
            phx-change="duration_unit_change"
            type="select"
            label="Duration time unit"
            options={Units.construct_duration_unit_options_list(use_primitives?: true)}
            value={@duration_unit}
          />

          <.input field={@form[:reported_duration]} type="text" label="Reported duration"
            value={@reported_duration || @duration || 0} readonly
          />
          <.input field={@form[:reported_duration_time_unit]}
            phx-change="reported_duration_unit_change"
            type="select" label="Reported duration time unit"
            options={Units.construct_duration_unit_options_list()}
            value={Units.get_default_billing_increment()}
          />
        </div>

        <.input field={@form[:description]} type="textarea" label="Description"
          placeholder={if @invocation_context == :start, do: "What are you working on?", else: "What did you work on?"} />

        <.input field={@form[:tag_id]} type="select" label="Tag" placeholder="Tag" options={@tags} />

        <:actions>
          <.button :if={@invocation_context == :start} phx-disable-with="Saving...">Start</.button>
          <.button :if={@invocation_context == :stop} phx-disable-with="Saving...">Stop</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{timer: timer} = assigns, socket) do
    changeset = TimeTracking.change_timer(timer)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_tag()
     |> assign_form(changeset)
    }
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

    start_timestamp = (Map.get(socket.assigns.form.params, "start_stamp", nil) || socket.assigns.timer.start_stamp)
    end_timestamp = (Map.get(socket.assigns.form.params, "end_stamp", nil) || socket.assigns.end_timestamp)
    duration = Klepsidra.TimeTracking.Timer.calculate_timer_duration(start_timestamp, end_timestamp, String.to_atom(duration_time_unit)) |> to_string()

    socket =
      assign(socket, duration: duration, duration_unit: duration_time_unit)

    {:noreply, socket}
  end

  def handle_event("reported_duration_unit_change", params, socket) do
    %{"timer" => %{"reported_duration_time_unit" => reported_duration_time_unit}} = params

    start_timestamp = (Map.get(socket.assigns.form.params, "start_stamp", nil) || socket.assigns.timer.start_stamp)
    end_timestamp = (Map.get(socket.assigns.form.params, "end_stamp", nil) || socket.assigns.end_timestamp)
    duration = Klepsidra.TimeTracking.Timer.calculate_timer_duration(start_timestamp, end_timestamp, String.to_atom(reported_duration_time_unit)) |> to_string()

    socket =
      assign(socket, reported_duration: duration, reported_duration_time_unit: reported_duration_time_unit)

    {:noreply, socket}
  end

  def handle_event("end_stamp_change", params, socket) do
    %{"timer" => %{"end_stamp" => end_timestamp}} = params

    start_timestamp = (Map.get(socket.assigns.form.params, "start_stamp", nil) || socket.assigns.timer.start_stamp)
    duration_time_unit = socket.assigns.duration_unit
    reported_duration_time_unit = (Map.get(socket.assigns, :reported_duration_time_unit, nil) || socket.assigns.reported_duration_unit)
    duration = Klepsidra.TimeTracking.Timer.calculate_timer_duration(start_timestamp, end_timestamp, String.to_atom(duration_time_unit)) |> to_string()
    reported_duration = Klepsidra.TimeTracking.Timer.calculate_timer_duration(start_timestamp, end_timestamp, String.to_atom(reported_duration_time_unit)) |> to_string()

    {:noreply,
     assign(socket,
            end_stamp: end_timestamp,
            duration: duration,
            duration_time_unit: duration_time_unit,
            reported_duration: reported_duration,
            reported_duration_time_unit: reported_duration_time_unit)}
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

  defp assign_tag(socket) do
    tags =
      Klepsidra.Categorisation.list_tags()
      |> Enum.map(fn tag -> {tag.name, tag.id} end)

    assign(socket, :tags, tags)
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
