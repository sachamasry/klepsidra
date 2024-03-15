defmodule KlepsidraWeb.TimerLive.AutomatedTimer do
  use KlepsidraWeb, :live_component

  alias Klepsidra.TimeTracking

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
      <.input field={@form[:start_stamp]} type="datetime-local" label="Start time"
      value={@timer.start_stamp || @start_timestamp} readonly
      />

      <div :if={@invocation_context == :stop}>
      <.input field={@form[:end_stamp]} type="datetime-local" label="End time"
      value={@timer.end_stamp || @end_timestamp} />

        <.input field={@form[:duration]} type="number" label="Duration"
        value={@duration || 0} readonly
        />

    <.input field={@form[:duration_time_unit]}
    phx-change="duration_unit"
    type="select"
    label="Duration time unit"
    options={[{"Hours", "hour"}, {"Minutes", "minute"}, {"Seconds", "second"}]}
    value={@duration_unit}
    />

    <.input field={@form[:reported_duration]} type="number" label="Reported duration"
    value={@duration || 0} readonly
    />
    <.input field={@form[:reported_duration_time_unit]} type="select" label="Reported duration time unit"
    options={[{"Hours", "hour"}, {"Minutes", "minute"}, {"Seconds", "second"}]}
    value="minute"
    />
        </div>

        <.input field={@form[:description]} type="textarea" label="Description" />

        <.input field={@form[:tag_id]} type="select" placeholder="Tag" options={@tags} />

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

  def handle_event("duration_unit", params, socket) do
    %{"timer" => %{"duration_time_unit" => duration_unit}} = params
    start_timestamp = (Map.get(socket.assigns.form.params, "start_stamp", nil) || socket.assigns.timer.start_stamp)
    end_timestamp = (Map.get(socket.assigns.form.params, "end_stamp", nil) || socket.assigns.end_timestamp)
    duration = Klepsidra.TimeTracking.Timer.calculate_timer_duration(start_timestamp, end_timestamp, String.to_atom(duration_unit))

    socket =
    assign(socket, duration: to_string(duration), duration_unit: "seconds")

    IO.inspect(params, label: "Params")
    IO.inspect(socket.assigns.timer.end_stamp, label: "Timer end stamp")
    IO.inspect(socket.assigns.form.data.end_stamp, label: "Form end stamp")
    IO.inspect(Map.get(socket.assigns.form.params, "end_stamp", nil), label: "Form end stamp")
    IO.inspect(socket.assigns.end_timestamp, label: "Socket")
    # IO.inspect(socket, label: "Socket")

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
