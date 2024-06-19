defmodule Klepsidra.TimeTracking.Timer do
  @moduledoc """
  Defines the `timers` schema and functions needed to clock in, out and parse datetimes.
  """

  use Ecto.Schema

  import Ecto.Changeset
  alias Klepsidra.Categorisation.TimerTags
  alias Klepsidra.Projects.Project
  alias Klepsidra.BusinessPartners.BusinessPartner

  @type t :: %__MODULE__{
          start_stamp: String.t(),
          end_stamp: String.t(),
          duration: integer,
          duration_time_unit: String.t(),
          description: String.t(),
          billable: boolean,
          business_partner_id: integer,
          project_id: integer,
          reported_duration: integer,
          reported_duration_time_unit: String.t()
        }
  schema "timers" do
    field :start_stamp, :string
    field :end_stamp, :string
    field :duration, :integer, default: nil
    field :duration_time_unit, :string
    field :description, :string
    field :billable, :boolean, default: false

    belongs_to :business_partner, BusinessPartner
    belongs_to :project, Project

    field :reported_duration, :integer
    field :reported_duration_time_unit, :string

    has_many :timer_tags, TimerTags,
      preload_order: [asc: :tag_id],
      on_replace: :delete

    has_many :tags, through: [:timer_tags, :tag]

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
      :description,
      :billable,
      :business_partner_id,
      :project_id,
      :reported_duration,
      :reported_duration_time_unit
    ])
    |> validate_required(:start_stamp, message: "You must enter a start date and time")
    |> validate_timestamp(:start_stamp)
    |> validate_timestamp(:end_stamp)
    |> validate_timestamp_chronology(:start_stamp, :end_stamp)
    |> unique_constraint(:project)
  end

  @doc """
  Validates timestamp fields, ensuring that they conform to valid `NaiveDateTime`
  parseable values. This ensures not only that the timestamp is a correctly
  formated string, but also that the representation is a valid date and time, i.e.
  a 13th month, or 32nd day will be considered invalid.
  """
  @spec validate_timestamp(t, atom, Keyword.t()) :: t
  def validate_timestamp(changeset, field, opts \\ []) do
    message = Keyword.get(opts, :message, "Enter a valid date and time")

    date_time_stamp = get_change(changeset, field)

    case date_time_stamp do
      nil ->
        changeset

      "" ->
        changeset

      _ ->
        case parse_html_datetime(date_time_stamp) do
          {:ok, _datetime_stamp} -> changeset
          _ -> add_error(changeset, field, message)
        end
    end
  end

  @doc """
  Validate that the `end_timestamp` is chronologically after the `start_timestamp`.

  ## Options

      * `:message` - the message on failure, defaults to "Timestamps are not in valid order"

  """
  @spec validate_timestamp_chronology(t, atom, atom, Keyword.t()) :: t
  def validate_timestamp_chronology(changeset, start_timestamp, end_timestamp, opts \\ []) do
    message = Keyword.get(opts, :message, "Timestamps are not in valid order")
    start_stamp = get_field(changeset, start_timestamp, "")

    parsed_start_stamp =
      case parse_html_datetime(start_stamp) do
        {:ok, start_date_time_stamp} -> start_date_time_stamp
        _ -> nil
      end

    end_stamp = get_field(changeset, end_timestamp, "")

    parsed_end_stamp =
      case parse_html_datetime(end_stamp) do
        {:ok, end_date_time_stamp} -> end_date_time_stamp
        _ -> nil
      end

    with {:empty_start_stamp, true} <-
           {:empty_start_stamp, start_stamp != ""},
         true <- is_struct(parsed_start_stamp, NaiveDateTime),
         {:empty_end_stamp, true} <- {:empty_end_stamp, end_stamp != ""},
         true <- is_struct(parsed_end_stamp, NaiveDateTime),
         {:chronological_order, true} <-
           {:chronological_order, NaiveDateTime.before?(parsed_start_stamp, parsed_end_stamp)} do
      changeset
    else
      {:empty_start_stamp, false} ->
        changeset

      {:empty_end_stamp, false} ->
        changeset

      {:chronological_order, false} ->
        add_error(changeset, :end_stamp, "The end time must follow the start time")

      _ ->
        add_error(changeset, :end_stamp, message)
    end
  end

  @doc """
  Get the current local date and time, without a timezone component,
  for the timezone the the computer the program is running on is set to.

  This function will display what the date and time are right now, for the
  time zone configuration the computer is localised to.

  Relying on this function to return the time is fine for many uses, including for
  timing tasks, but is unsuitable for use where real precision and time awareness may be
  critical.

  Returns a `NaiveDateTime` struct.

  ## Examples

      iex> naivedatetime_stamp = Klepsidra.TimeTracking.Timer.get_current_timestamp()
      iex> naivedatetime_stamp.year >= 2024
      true
  """
  @spec get_current_timestamp() :: NaiveDateTime.t()
  def get_current_timestamp do
    NaiveDateTime.local_now()
  end

  @doc """
  Calculates the time elapsed between start and end timestamps.

  The time unit can be passed in as the optional `unit` argument. If it is omitted,
  minutes are used as the default time unit.

  In calculating the time duration, the difference between the two timestamps is
  always incremented by one. This ensures that if the timer were simply started
  and immediately stopped, it would still register the use of one unit of time.

  ## Examples

      iex> Klepsidra.TimeTracking.Timer.calculate_timer_duration("2024-02-28 12:34", "2024-02-28 13:45")
      72

      iex> Klepsidra.TimeTracking.Timer.calculate_timer_duration("2024-02-28 12:34", "2024-02-28 13:45", :minute)
      72

      iex> Klepsidra.TimeTracking.Timer.calculate_timer_duration("2024-02-28 12:34", "2024-02-28 13:45", :second)
      4261

      iex> Klepsidra.TimeTracking.Timer.calculate_timer_duration("2024-02-28 12:34", "2024-02-28 13:45", :hour)
      2

      iex> Klepsidra.TimeTracking.Timer.calculate_timer_duration("2024-02-28 12:34", "2024-02-28 13:34", :hour)
      2

      iex> Klepsidra.TimeTracking.Timer.calculate_timer_duration("2024-02-28 12:34", "2024-02-28 13:33", :hour)
      1

      iex> Klepsidra.TimeTracking.Timer.calculate_timer_duration(~N[2024-06-06 23:40:31], ~N[2024-06-07 01:23:45])
      104

      iex> Klepsidra.TimeTracking.Timer.calculate_timer_duration(~N[2024-06-06 23:40:31], ~N[2024-06-07 01:23:45], :minute)
      104

      iex> Klepsidra.TimeTracking.Timer.calculate_timer_duration(~N[2024-06-06 23:40:31], ~N[2024-06-07 01:23:45], :second)
      6195

      iex> Klepsidra.TimeTracking.Timer.calculate_timer_duration(~N[2024-06-06 23:40:31], ~N[2024-06-07 01:23:45], :hour)
      2
  """
  @spec calculate_timer_duration(String.t(), String.t(), atom()) :: integer()
  @spec calculate_timer_duration(NaiveDateTime.t(), NaiveDateTime.t(), atom()) :: integer()
  def calculate_timer_duration(start_timestamp, end_timestamp, unit \\ :minute)

  def calculate_timer_duration(start_timestamp, end_timestamp, unit)
      when is_bitstring(start_timestamp) and is_bitstring(end_timestamp) and is_atom(unit) do
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
    if unit in [:second, :minute, :hour, :day] do
      NaiveDateTime.diff(end_timestamp, start_timestamp, unit) + 1
    else
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

  An error is returned if the datetime string cannot be parsed as a valid date and time,
  and also if the string doesn't match the expected pattern.

  ## Examples

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime("1970-01-01T11:15")
      {:ok, ~N[1970-01-01 11:15:00]}

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime("1970-01-01T11:15:39")
      {:ok, ~N[1970-01-01 11:15:39]}

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime("1970-01-01 11:15")
      {:ok, ~N[1970-01-01 11:15:00]}

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime("1970-01-01 11:15:59")
      {:ok, ~N[1970-01-01 11:15:59]}

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime("1970-02-29T11:15")
      {:error, :invalid_date}

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime("")
      {:error, "Invalid argument passed as timestamp"}

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime(nil)
      {:error, "Invalid argument passed as timestamp"}
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

  def parse_html_datetime(
        <<_year::binary-size(4), "-", _month::binary-size(2), "-", _day::binary-size(2), "T",
          _hour::binary-size(2), ":", _minute::binary-size(2), ":",
          _second::binary-size(2)>> = datetime_string
      )
      when is_bitstring(datetime_string) do
    Timex.parse(datetime_string, "{YYYY}-{0M}-{0D}T{0h24}:{0m}:{0s}")
  end

  def parse_html_datetime(
        <<_year::binary-size(4), "-", _month::binary-size(2), "-", _day::binary-size(2), " ",
          _hour::binary-size(2), ":", _minute::binary-size(2), ":",
          _second::binary-size(2)>> = datetime_string
      )
      when is_bitstring(datetime_string) do
    Timex.parse(datetime_string, "{YYYY}-{0M}-{0D} {0h24}:{0m}:{0s}")
  end

  def parse_html_datetime(_), do: {:error, "Invalid argument passed as timestamp"}

  @doc """
  Parses HTML `datetime-local` strings into `NativeDateTime` structure.

  Works just like `parse_html_datetime\1`, but instead of returning an {:ok, _} or
  {:error, reason} tuple, returns the `NaiveDateTime` struct on success, raising
  an error otherwise.

  ## Examples

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime!("1970-01-01T11:15")
      ~N[1970-01-01 11:15:00]

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime!("1970-01-01T11:15:39")
      ~N[1970-01-01 11:15:39]

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime!("1970-01-01 11:15")
      ~N[1970-01-01 11:15:00]

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime!("1970-01-01 11:15:59")
      ~N[1970-01-01 11:15:59]

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

  def parse_html_datetime!(
        <<_year::binary-size(4), "-", _month::binary-size(2), "-", _day::binary-size(2), "T",
          _hour::binary-size(2), ":", _minute::binary-size(2), ":",
          _second::binary-size(2)>> = datetime_string
      )
      when is_bitstring(datetime_string) do
    Timex.parse!(datetime_string, "{YYYY}-{0M}-{0D}T{0h24}:{0m}:{0s}")
  end

  def parse_html_datetime!(
        <<_year::binary-size(4), "-", _month::binary-size(2), "-", _day::binary-size(2), " ",
          _hour::binary-size(2), ":", _minute::binary-size(2), ":",
          _second::binary-size(2)>> = datetime_string
      )
      when is_bitstring(datetime_string) do
    Timex.parse!(datetime_string, "{YYYY}-{0M}-{0D} {0h24}:{0m}:{0s}")
  end

  @doc """
  Converts `NativeDateTime` structure to HTML-ready string, with the seconds component
  elided.

  Returns a tuple with `:ok` or `:error` as the first element, with a string
  compatible with HTML's input `datetime-local` element, in the format
  "YYYY-MM-DDThh:mm". This can directly be fed into an `input` element's `value`
  slot.

  ## Examples

      iex> Klepsidra.TimeTracking.Timer.convert_naivedatetime_to_html(~N[2024-04-07 22:12:32])
      {:ok, "2024-04-07T22:12:32"}
  """
  @spec convert_naivedatetime_to_html(NaiveDateTime.t()) ::
          {:ok, String.t()} | {:error, String.t()}
  def convert_naivedatetime_to_html(datetime_stamp)
      when is_struct(datetime_stamp, NaiveDateTime) do
    Timex.format(datetime_stamp, "{YYYY}-{0M}-{0D}T{0h24}:{0m}:{0s}")
  end

  @doc """
  Converts `NativeDateTime` structure to HTML-ready string, with the seconds component
  elided.

  Returns a string compatible with HTML's input `datetime-local` element, in the
  format "YYYY-MM-DDThh:mm". This can directly be fed into an `input` element's
  `value` slot.

  ## Examples

      iex> Klepsidra.TimeTracking.Timer.convert_naivedatetime_to_html!(~N[2024-04-07 22:12:32])
      "2024-04-07T22:12:32"
  """
  @spec convert_naivedatetime_to_html!(NaiveDateTime.t()) :: String.t()
  def convert_naivedatetime_to_html!(datetime_stamp)
      when is_struct(datetime_stamp, NaiveDateTime) do
    Timex.format!(datetime_stamp, "{YYYY}-{0M}-{0D}T{0h24}:{0m}:{0s}")
  end

  @doc """
  Formats a number into a string according to a unit definition for a locale.

  Takes an integer duration, and an atom time unit, including any custom time
  units defined and compiled as part of this project.

  Returns a tuple {:ok, ...} containing a locale-specific and quantity-sensitive
  pluralisation of the defined time unit as a string.

  ## Examples

      iex> Klepsidra.TimeTracking.Timer.duration_to_string(3, :minute)
      {:ok, "3 minutes"}

      iex> Klepsidra.TimeTracking.Timer.duration_to_string(7, :six_minute_increment)
      {:ok, "7 six minute increments"}

      iex> Klepsidra.TimeTracking.Timer.duration_to_string(1, :hour)
      {:ok, "1 hour"}

      iex> Klepsidra.TimeTracking.Timer.duration_to_string(0, :second)
      {:ok, "0 seconds"}
  """
  @spec duration_to_string(integer(), atom()) :: []
  def duration_to_string(duration, time_unit) when is_integer(duration) and is_atom(time_unit) do
    Cldr.Unit.to_string(Cldr.Unit.new!(time_unit, duration), Klepsidra.Cldr)
  end
end
