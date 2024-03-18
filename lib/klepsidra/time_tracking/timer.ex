defmodule Klepsidra.TimeTracking.Timer do
  use Ecto.Schema

  import Ecto.Changeset
  alias Klepsidra.Categorisation.Tag 

  schema "timers" do
    field :description, :string
    field :start_stamp, :string
    field :end_stamp, :string
    field :duration, :integer, default: nil
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
    calculate_timer_duration(
      parse_html_datetime!(start_timestamp),
      parse_html_datetime!(end_timestamp),
      unit)
  end

  def calculate_timer_duration(start_timestamp, end_timestamp, unit \\ :minute) when is_struct(start_timestamp, NaiveDateTime) and is_struct(end_timestamp, NaiveDateTime) and is_atom(unit) do
    cond do
      unit in [:second, :minute, :hour, :day] ->
        NaiveDateTime.diff(end_timestamp, start_timestamp, unit) + 1

      true ->
        NaiveDateTime.diff(end_timestamp, start_timestamp, :minute) + 1
        |> Cldr.Unit.new!(:minute)
        |> Klepsidra.Cldr.Unit.convert!(unit)
        |> Map.get(:value)
        |> Decimal.round(0, :up)
    end
  end

  @doc """
  Clock out of an active timer, given a starting timestamp string.

  Returns the ending timestamp and duration in the requested unit of time.
  """
  def clock_out(start_timestamp, unit \\ :minute) when is_bitstring(start_timestamp) and is_atom(unit) do
    end_timestamp = get_current_timestamp()

    start_timestamp
    |> parse_html_datetime()
    |> case do
         {:ok, start_timestamp} -> %{
                                   end_timestamp: convert_naivedatetime_to_html!(end_timestamp),
                                   timer_duration: calculate_timer_duration(start_timestamp,
                                     end_timestamp,
                                     unit)}
         {:error, _} -> nil
       end
  end

  @doc """
  Parses HTML `datetime-local` strings into `NativeDateTime` structures.

  Datetime strings coming from HTML, from `datetime-local` type fields,
  are not conformant to the extended date and time of day  ISO 8601:2019 standard format.
  Specifically, they are encoded as "YYYY-MM-DDThh:mm", and are generally (but not always)
  passed without a seconds component. `NativeDateTime` cannot parse this, returning an
  error.

  Using the Timex library's `parse/2` function, parse these strings into an ISO
  conforming `NativeDateTime` structure, returning it.
  """
  def parse_html_datetime(datetime_string) when is_bitstring(datetime_string) do
    Timex.parse(datetime_string, "{YYYY}-{0M}-{0D}T{0h24}:{0m}")
  end
  def parse_html_datetime!(datetime_string) when is_bitstring(datetime_string) do
    Timex.parse!(datetime_string, "{YYYY}-{0M}-{0D}T{0h24}:{0m}")
  end

  @doc """
  Convert `NativeDateTime` structure to HTML-ready string, with the seconds component
  elided.

  Returns a `datetime-local` compatible string, in the format "YYYY-MM-DDThh:mm". This
  can directly be fed into an `input` element's `value` slot.
  """
  def convert_naivedatetime_to_html(datetime_stamp) when is_struct(datetime_stamp, NaiveDateTime) do
    Timex.format(datetime_stamp, "{YYYY}-{0M}-{0D}T{0h24}:{0m}")
  end
  def convert_naivedatetime_to_html!(datetime_stamp) when is_struct(datetime_stamp, NaiveDateTime) do
    Timex.format!(datetime_stamp, "{YYYY}-{0M}-{0D}T{0h24}:{0m}")
  end

  @doc """
  Formats a number into a string according to a unit definition for a locale.
  """
  def duration_to_string(duration, time_unit) when is_integer(duration) and is_atom(time_unit) do
    Cldr.Unit.to_string(Cldr.Unit.new!(time_unit, duration), Klepsidra.Cldr)
  end
end
