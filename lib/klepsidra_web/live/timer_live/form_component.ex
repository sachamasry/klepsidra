defmodule KlepsidraWeb.TimerLive.FormComponent do
  @moduledoc false

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
        <.input field={@form[:start_stamp]} type="datetime-local" label="Start time" />
        <.input field={@form[:end_stamp]} type="datetime-local" label="End imestamp" />
        <.input field={@form[:duration]} type="number" label="Duration" />
        <.input
          field={@form[:duration_time_unit]}
          type="select"
          label="Duration time unit"
          options={[{"Hours", "hour"}, {"Minutes", "minute"}, {"Seconds", "second"}]}
          value="minute"
        />
        <.input field={@form[:reported_duration]} type="number" label="Reported duration" />
        <.input
          field={@form[:reported_duration_time_unit]}
          type="select"
          label="Reported duration time unit"
          options={[{"Hours", "hour"}, {"Minutes", "minute"}, {"Seconds", "second"}]}
          value="minute"
        />
        <.input field={@form[:description]} type="textarea" label="Description" />

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
     #  |> assign_tag()
     |> assign_form(changeset)}
  end

  # @impl true
  # def handle_event("validate", %{"timer" => %{"tag_id" => "new"} = _timer_params}, socket) do
  #   # Launch new tag modal

  #   # Refresh list

  #   {:noreply, socket}
  # end

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

  defp save_timer(socket, :edit, timer_params) do
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

  defp save_timer(socket, :new, timer_params) do
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

  # defp assign_tag(socket) do
  #   tags =
  #     Klepsidra.Categorisation.list_tags()
  #     |> Enum.map(fn tag -> {tag.name, tag.id} end)
  #     |> Kernel.++([{"+ New tag", :new}])

  #   assign(socket, :tags, tags)
  # end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
