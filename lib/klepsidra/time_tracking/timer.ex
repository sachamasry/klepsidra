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
    |> cast(attrs, [
      :start_stamp,
      :end_stamp,
      :duration,
      :duration_time_unit,
      :reported_duration,
      :reported_duration_time_unit,
      :description,
      :tag_id
    ])
    |> validate_required([:start_stamp])
    |> unique_constraint(:tag)
  end

  @doc """
  Get the current local date and time without a timezone component.

  Returns a `NaiveDateTime` struct.
  """
  @spec get_current_timestamp() :: NaiveDateTime.t()
  def get_current_timestamp() do
    NaiveDateTime.local_now()
  end

  @doc """
  Calculates the time elapsed between start and end timestamps.

  The time unit can be passed in as the optional `unit` argument. If it is omitted,
  minutes are used as the default time unit.
  """
  @spec calculate_timer_duration(String.t(), String.t(), atom()) :: integer()
  @spec calculate_timer_duration(NaiveDateTime.t(), NaiveDateTime.t(), atom()) :: integer()
  def calculate_timer_duration(start_timestamp, end_timestamp, unit \\ :minute)

  def calculate_timer_duration(start_timestamp, end_timestamp, unit)
      when is_bitstring(start_timestamp) and is_bitstring(end_timestamp) and
             is_atom(unit) do
    calculate_timer_duration(
      parse_html_datetime!(start_timestamp),
      parse_html_datetime!(end_timestamp),
      unit
    )
  end

  def calculate_timer_duration(start_timestamp, end_timestamp, unit)
      when is_struct(start_timestamp, NaiveDateTime) and
             is_struct(
               end_timestamp,
               NaiveDateTime
             ) and is_atom(unit) do
    cond do
      unit in [:second, :minute, :hour, :day] ->
        NaiveDateTime.diff(end_timestamp, start_timestamp, unit) + 1

      true ->
        (NaiveDateTime.diff(end_timestamp, start_timestamp, :minute) + 1)
        |> Cldr.Unit.new!(:minute)
        |> Klepsidra.Cldr.Unit.convert!(unit)
        |> Map.get(:value)
        |> Decimal.round(0, :up)
    end
  end

  @doc """
  Clock out of an active timer, given a starting timestamp string.

  ## Return values

  Returns a map containing the ending timestamp and duration in the requested unit of time.

  ## Examples

      iex> Klepsidra.TimeTracking.Timer.get_current_timestamp()
      ...> |> NaiveDateTime.add(-15, :minute)
      ...> |> Klepsidra.TimeTracking.Timer.convert_naivedatetime_to_html!()
      ...> |> Klepsidra.TimeTracking.Timer.clock_out()
      %{end_timestamp: Klepsidra.TimeTracking.Timer.get_current_timestamp() |> Klepsidra.TimeTracking.Timer.convert_naivedatetime_to_html!(), timer_duration: 16}

      iex> Klepsidra.TimeTracking.Timer.get_current_timestamp()
      ...> |> NaiveDateTime.add(-15, :minute)
      ...> |> Klepsidra.TimeTracking.Timer.convert_naivedatetime_to_html!()
      ...> |> Klepsidra.TimeTracking.Timer.clock_out(:hour)
      %{end_timestamp: Klepsidra.TimeTracking.Timer.get_current_timestamp() |> Klepsidra.TimeTracking.Timer.convert_naivedatetime_to_html!(), timer_duration: 1}
  """
  @spec clock_out(String.t(), atom()) :: %{end_timestamp: String.t(), timer_duration: integer()}
  def clock_out(start_timestamp, unit \\ :minute)
      when is_bitstring(start_timestamp) and is_atom(unit) do
    end_timestamp = get_current_timestamp()

    %{
      end_timestamp: convert_naivedatetime_to_html!(end_timestamp),
      timer_duration:
        calculate_timer_duration(
          parse_html_datetime!(start_timestamp),
          end_timestamp,
          unit
        )
    }
  end

  @doc """
  Parses HTML `datetime-local` strings into `NativeDateTime` structure.

  Datetime strings coming from HTML, from `datetime-local` type fields,
  are not conformant to the extended date and time of day  ISO 8601:2019 standard format.
  Specifically, they are encoded as "YYYY-MM-DDThh:mm", and are generally (but not always)
  passed without a seconds component. `NativeDateTime` cannot parse this, returning an
  error.

  Using the Timex library's `parse/2` function, parse datetime strings into an ISO
  conforming `NativeDateTime` structure, returning a result tuple:

  `{:ok, ~N[...]}` on success, or {:error, reason} upon failure.

  It is possible to receive a datetime with date and time components separated by either
  a letter "t" or a single space (" "), binary pattern matching will determine which is
  received in the `datetime_string` argument.

  ## Examples

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime("1970-01-01T11:15")
      {:ok, ~N[1970-01-01 11:15:00]}

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime("1970-01-01 11:15")
      {:ok, ~N[1970-01-01 11:15:00]}

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime("1970-02-29T11:15")
      {:error, :invalid_date}
  """
  @spec parse_html_datetime(String.t()) :: {:ok, NaiveDateTime.t()} | {:error, String.t()}
  def parse_html_datetime(
        <<_year::binary-size(4), "-", _month::binary-size(2), "-", _day::binary-size(2), "T",
          _hour::binary-size(2), ":", _minute::binary-size(2)>> = datetime_string
      )
      when is_bitstring(datetime_string) do
    Timex.parse(datetime_string, "{YYYY}-{0M}-{0D}T{0h24}:{0m}")
  end

  def parse_html_datetime(
        <<_year::binary-size(4), "-", _month::binary-size(2), "-", _day::binary-size(2), " ",
          _hour::binary-size(2), ":", _minute::binary-size(2)>> = datetime_string
      )
      when is_bitstring(datetime_string) do
    Timex.parse(datetime_string, "{YYYY}-{0M}-{0D} {0h24}:{0m}")
  end

  @doc """
  Parses HTML `datetime-local` strings into `NativeDateTime` structure.

  Works just like `parse_html_datetime\1`, but instead of returning an {:ok, _} or
  {:error, reason} tuple, returns the `NaiveDateTime` struct on success, otherwise
  raises an error.

  ## Examples

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime("1970-01-01T11:15")
      {:ok, ~N[1970-01-01 11:15:00]}

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime("1970-01-01 11:15")
      {:ok, ~N[1970-01-01 11:15:00]}

  """
  @spec parse_html_datetime!(String.t()) :: NaiveDateTime.t()
  def parse_html_datetime!(
        <<_year::binary-size(4), "-", _month::binary-size(2), "-", _day::binary-size(2), "T",
          _hour::binary-size(2), ":", _minute::binary-size(2)>> = datetime_string
      )
      when is_bitstring(datetime_string) do
    Timex.parse!(datetime_string, "{YYYY}-{0M}-{0D}T{0h24}:{0m}")
  end

  def parse_html_datetime!(
        <<_year::binary-size(4), "-", _month::binary-size(2), "-", _day::binary-size(2), " ",
          _hour::binary-size(2), ":", _minute::binary-size(2)>> = datetime_string
      )
      when is_bitstring(datetime_string) do
    Timex.parse!(datetime_string, "{YYYY}-{0M}-{0D} {0h24}:{0m}")
  end

  @doc """
  Convert `NativeDateTime` structure to HTML-ready string, with the seconds component
  elided.

  Returns a `datetime-local` compatible string, in the format "YYYY-MM-DDThh:mm". This
  can directly be fed into an `input` element's `value` slot.
  """
  @spec convert_naivedatetime_to_html(NaiveDateTime.t()) ::
          {:ok, String.t()} | {:error, String.t()}
  def convert_naivedatetime_to_html(datetime_stamp)
      when is_struct(datetime_stamp, NaiveDateTime) do
    Timex.format(datetime_stamp, "{YYYY}-{0M}-{0D}T{0h24}:{0m}")
  end

  @spec convert_naivedatetime_to_html(NaiveDateTime.t()) :: String.t()
  def convert_naivedatetime_to_html!(datetime_stamp)
      when is_struct(datetime_stamp, NaiveDateTime) do
    Timex.format!(datetime_stamp, "{YYYY}-{0M}-{0D}T{0h24}:{0m}")
  end

  @doc """
  Formats a number into a string according to a unit definition for a locale.
  """
  @spec duration_to_string(integer(), atom()) :: []
  def duration_to_string(duration, time_unit) when is_integer(duration) and is_atom(time_unit) do
    Cldr.Unit.to_string(Cldr.Unit.new!(time_unit, duration), Klepsidra.Cldr)
  end
end
