defmodule Klepsidra.TimeTracking.Timer do
  use Ecto.Schema
  import Ecto.Changeset
  alias Klepsidra.Categorisation.Tag 

  schema "timers" do
    field :description, :string
    field :start_stamp, :string
    field :end_stamp, :string
    field :duration, :integer, default: 0
    field :duration_time_unit, :string
    field :reported_duration, :integer
    field :reported_duration_time_unit, :string

    belongs_to :tag, Tag

    timestamps()
  end

  @doc false
  def changeset(timer, attrs) do
    timer
    |> cast(attrs, [:start_stamp, :end_stamp, :duration, :duration_time_unit, :reported_duration, :reported_duration_time_unit, :description, :tag_id])
    |> validate_required([:start_stamp])
    |> unique_constraint(:tag)
  end

  @doc """
  Gets the current local date and time, without a timezone component
  """
  def get_current_timestamp() do
    NaiveDateTime.local_now()
  end

  @doc """
  Calculates the time elapsed between start and end timestamps, in minutes
  """
  def calculate_timer_duration(start_timestamp, end_timestamp, unit) when is_bitstring(start_timestamp) and is_bitstring(end_timestamp) and is_atom(unit) do
    calculate_timer_duration(NaiveDateTime.from_iso8601!(start_timestamp), NaiveDateTime.from_iso8601!(end_timestamp), unit)
  end

  def calculate_timer_duration(start_timestamp, end_timestamp, unit \\ :minute) when is_struct(start_timestamp, NaiveDateTime) and is_struct(end_timestamp, NaiveDateTime) and is_atom(unit) do
    NaiveDateTime.diff(end_timestamp, start_timestamp, unit) + 1
  end

  @doc """
  Clock out of an active timer, given a starting timestamp string.

  Returns the ending timestamp and duration in the requested unit of time.
  """
  def clock_out(start_timestamp, unit \\ :minute) when is_bitstring(start_timestamp) and is_atom(unit) do
    end_timestamp = get_current_timestamp()

    start_timestamp <> ":00"
    |> NaiveDateTime.from_iso8601()
    |> case do
         {:ok, start_timestamp} -> %{end_timestamp: end_timestamp, timer_duration: calculate_timer_duration(start_timestamp, end_timestamp, unit)}
         {:error, _} -> nil
       end
  end
end
