defmodule Klepsidra.TimeTracking do
  @moduledoc """
  The TimeTracking context.
  """

  import Ecto.Query, warn: false
  alias Klepsidra.Repo
  alias Klepsidra.TimeTracking.ActivityType
  alias Klepsidra.TimeTracking.Note
  alias Klepsidra.TimeTracking.Timer

  @doc """
  Returns the list of timers.

  ## Examples

      iex> list_timers()
      [%Timer{}, ...]

  """
  def list_timers do
    Timer |> order_by(desc: :start_stamp) |> Repo.all()
  end

  @spec list_timers(filter :: map()) :: {non_neg_integer(), map()}
  def list_timers(
        %{
          from: from,
          to: to,
          project_id: project_id,
          business_partner_id: business_partner_id,
          activity_type_id: activity_type_id,
          billable: billable,
          modified: modified
        } =
          filter
      )
      when is_map(filter) do
    order_by = [asc: :inserted_at]

    query =
      from(
        at in Timer,
        left_join: p in assoc(at, :project),
        left_join: bp in assoc(at, :business_partner),
        left_join: act in assoc(at, :activity_type),
        where: not is_nil(at.end_stamp),
        order_by: ^order_by,
        select: %{
          id: at.id,
          start_stamp: at.start_stamp,
          end_stamp: at.end_stamp,
          duration: at.duration,
          duration_time_unit: at.duration_time_unit,
          project_id: p.id,
          project_name: p.name |> coalesce(""),
          business_partner_id: at.business_partner_id,
          business_partner_name: bp.name |> coalesce(""),
          billable: at.billable,
          billing_duration: at.billing_duration,
          billing_duration_time_unit: at.billing_duration_time_unit,
          billing_rate: at.billing_rate,
          activity_type_id: act.id,
          activity_type: act.name |> coalesce(""),
          description: at.description |> coalesce(""),
          inserted_at: at.inserted_at,
          updated_at: at.updated_at,
          modified: fragment("iif(? != ?, true, false)", at.inserted_at, at.updated_at)
        }
      )

    inner_query =
      query
      |> filter_by_date(%{from: from, to: to})
      |> filter_by_project_id(%{project_id: project_id})
      |> filter_by_business_partner_id(%{business_partner_id: business_partner_id})
      |> filter_by_activity_type_id(%{activity_type_id: activity_type_id})
      |> filter_by_billable(%{billable: billable})

    list_query =
      from(at in subquery(inner_query))

    timer_list =
      list_query
      |> filter_by_modification_status(%{modified: modified})
      |> Repo.all()

    result_count =
      list_query
      |> filter_by_modification_status(%{modified: modified})
      |> select([at], count(at.id))
      |> Repo.one()

    {result_count, timer_list}
  end

  defp filter_by_date(query, %{from: "", to: ""}), do: query

  defp filter_by_date(query, %{from: from, to: ""}) do
    where(query, [at], at.start_stamp >= ^from)
  end

  defp filter_by_date(query, %{from: "", to: to}) do
    where(query, [at], at.end_stamp <= ^to)
  end

  defp filter_by_date(query, %{from: from, to: to}) do
    query
    |> where([at], at.start_stamp >= ^from)
    |> where([at], at.end_stamp <= ^to)
  end

  defp filter_by_project_id(query, %{project_id: ""}), do: query

  defp filter_by_project_id(query, %{project_id: project_id}) do
    query
    |> where([at], at.project_id == ^project_id)
  end

  defp filter_by_business_partner_id(query, %{business_partner_id: ""}), do: query

  defp filter_by_business_partner_id(query, %{business_partner_id: business_partner_id}) do
    query
    |> where([at], at.business_partner_id == ^business_partner_id)
  end

  defp filter_by_activity_type_id(query, %{activity_type_id: ""}), do: query

  defp filter_by_activity_type_id(query, %{activity_type_id: activity_type_id}) do
    query
    |> where([at], at.activity_type_id == ^activity_type_id)
  end

  defp filter_by_billable(query, %{billable: ""}), do: query

  defp filter_by_billable(query, %{billable: billable}) do
    query
    |> where([at], at.billable == ^billable)
  end

  defp filter_by_modification_status(query, %{modified: ""}), do: query

  defp filter_by_modification_status(query, %{modified: modified}) when is_bitstring(modified) do
    query
    |> where([at], at.modified == ^String.to_integer(modified))
  end

  defp filter_by_modification_status(query, %{modified: modified}) when is_integer(modified) do
    query
    |> where([at], at.modified == ^modified)
  end

  @doc """
  Returns the list of timers, along with the associated tags.

  ## Examples

      iex> list_timers_with_tags()
      [%Timer{}, ...]

  """
  def list_timers_with_tags do
    query =
      from(
        at in Timer,
        order_by: [desc: :start_stamp],
        preload: :tags
      )

    Repo.all(query)
  end

  @doc """
  Returns the list of timers, with `business_partner` association preloaded.

  ## Examples

      iex> list_timers()
      [%Timer{}, ...]

  """
  def list_timers_with_customers do
    query =
      from(
        at in Timer,
        left_join: bp in assoc(at, :business_partner),
        left_join: p in assoc(at, :project),
        order_by: [desc: at.inserted_at, asc: at.id],
        select: %{
          id: at.id,
          start_stamp: at.start_stamp,
          end_stamp: at.end_stamp,
          duration: at.duration,
          duration_time_unit: at.duration_time_unit,
          billing_duration: at.billing_duration,
          billing_duration_time_unit: at.billing_duration_time_unit,
          description: at.description |> coalesce(""),
          project_name: p.name |> coalesce(""),
          business_partner_id: at.business_partner_id,
          business_partner_name: bp.name |> coalesce(""),
          inserted_at: at.inserted_at
        }
      )

    query
    |> Repo.all()
    |> Enum.map(fn rec ->
      Map.merge(rec, %{
        start_stamp:
          Timer.format_human_readable_time!(Timer.parse_html_datetime!(rec.start_stamp)),
        end_stamp:
          if(rec.end_stamp,
            do: Timer.format_human_readable_time!(Timer.parse_html_datetime!(rec.end_stamp))
          ),
        summary:
          rec.description
          |> markdown_to_html()
          |> Phoenix.HTML.raw(),
        formatted_start_date: nil,
        formatted_duration:
          {rec.duration, rec.duration_time_unit}
          |> Timer.convert_duration_to_base_time_unit()
          |> Klepsidra.TimeTracking.Timer.format_human_readable_duration()
      })
    end)
  end

  @doc """
  Gets a single timer.

  Raises `Ecto.NoResultsError` if the Timer does not exist.

  ## Examples

      iex> get_timer!(123)
      %Timer{}

      iex> get_timer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_timer!(id), do: Repo.get!(Timer, id)

  @doc """
  Gets a single timer, with its `business_partner` association preloaded.

  Raises `Ecto.NoResultsError` if the Timer does not exist.

  ## Examples

      iex> get_timer!(123)
      %Timer{}

      iex> get_timer!(456)
      ** (Ecto.NoResultsError)
  """
  def get_formatted_timer_record!(id) do
    query =
      from(at in Timer,
        where: at.id == ^id,
        left_join: p in assoc(at, :project),
        left_join: bp in assoc(at, :business_partner),
        left_join: act in assoc(at, :activity_type),
        select: %{
          id: at.id,
          start_stamp: at.start_stamp,
          end_stamp: at.end_stamp,
          duration: at.duration,
          duration_time_unit: at.duration_time_unit,
          project_id: p.id,
          project_name: p.name |> coalesce(""),
          business_partner_id: at.business_partner_id,
          business_partner_name: bp.name |> coalesce(""),
          billable: at.billable,
          billing_duration: at.billing_duration,
          billing_duration_time_unit: at.billing_duration_time_unit,
          billing_rate: at.billing_rate,
          activity_type_id: act.id,
          activity_type: act.name |> coalesce(""),
          description: at.description |> coalesce(""),
          inserted_at: at.inserted_at
        }
      )

    query
    |> Repo.all()
    |> Enum.map(fn rec ->
      Map.merge(rec, %{
        start_stamp:
          Timer.format_human_readable_time!(Timer.parse_html_datetime!(rec.start_stamp)),
        end_stamp:
          if(rec.end_stamp,
            do: Timer.format_human_readable_time!(Timer.parse_html_datetime!(rec.end_stamp))
          ),
        summary:
          rec.description
          |> markdown_to_html()
          |> Phoenix.HTML.raw(),
        formatted_start_date: "",
        formatted_duration:
          {rec.duration, rec.duration_time_unit}
          |> Timer.convert_duration_to_base_time_unit()
          |> Klepsidra.TimeTracking.Timer.format_human_readable_duration()
      })
    end)
    |> List.first()
  end

  @doc """
  Gets a list of closed timers started on the specified date.

  A closed timer is one which has an end datetime stamp recorded, as well as
  a starting one.
  """
  @spec get_closed_timers_for_date(NaiveDateTime.t()) ::
          [Klepsidra.TimeTracking.Timer.t(), ...] | []
  def get_closed_timers_for_date(date) when is_struct(date, NaiveDateTime) do
    start_of_day = NaiveDateTime.beginning_of_day(date)
    end_of_day = NaiveDateTime.add(start_of_day, 24, :hour)

    query =
      from(
        at in Timer,
        left_join: bp in assoc(at, :business_partner),
        left_join: p in assoc(at, :project),
        where:
          at.start_stamp <= type(^end_of_day, :naive_datetime) and
            at.end_stamp >= type(^start_of_day, :naive_datetime) and
            not is_nil(at.end_stamp),
        order_by: [desc: at.inserted_at, asc: at.id],
        select: %{
          id: at.id,
          start_stamp: at.start_stamp,
          end_stamp: at.end_stamp,
          duration: at.duration,
          duration_time_unit: at.duration_time_unit,
          description: at.description |> coalesce(""),
          project_name: p.name |> coalesce(""),
          business_partner_id: at.business_partner_id,
          business_partner_name: bp.name |> coalesce(""),
          inserted_at: at.inserted_at
        }
      )

    query
    |> Repo.all()
    |> Enum.map(fn rec ->
      Map.merge(rec, %{
        start_stamp:
          Timer.format_human_readable_time!(Timer.parse_html_datetime!(rec.start_stamp)),
        end_stamp: Timer.format_human_readable_time!(Timer.parse_html_datetime!(rec.end_stamp)),
        summary:
          rec.description
          |> markdown_to_html()
          |> Phoenix.HTML.raw(),
        formatted_start_date:
          if(
            NaiveDateTime.compare(Timer.parse_html_datetime!(rec.start_stamp), start_of_day) ==
              :lt,
            do: "Started yesterday",
            else: ""
          ),
        formatted_duration:
          {rec.duration, rec.duration_time_unit}
          |> Timer.convert_duration_to_base_time_unit()
          |> Klepsidra.TimeTracking.Timer.format_human_readable_duration()
      })
    end)
  end

  @doc """
  """
  def truncate(text, opts) do
    max_length = opts[:max_length] || 59
    omission = opts[:omission] || "..."

    cond do
      not String.valid?(text) ->
        text

      String.length(text) < max_length ->
        text

      true ->
        length_with_omission = max_length - String.length(omission)

        "#{String.slice(text, 0, length_with_omission)}#{omission}"
    end
  end

  @doc """
  """
  def markdown_to_html(markdown, _options \\ []) do
    markdown
    |> Earmark.as_html!(
      compact_output: true,
      code_class_prefix: "lang-",
      smartypants: true
    )
    |> HtmlSanitizeEx.html5()
  end

  @doc """
  Gets a count of closed timers started on the specified date.

  A closed timer is one which has an end datetime stamp recorded, as well as
  a starting one.
  """
  @spec get_closed_timer_count_for_date(NaiveDateTime.t()) :: integer()
  def get_closed_timer_count_for_date(date) when is_struct(date, NaiveDateTime) do
    start_of_day = NaiveDateTime.beginning_of_day(date)
    end_of_day = NaiveDateTime.add(start_of_day, 24, :hour)

    query =
      from(
        at in "timers",
        select: count(at.id),
        where:
          at.start_stamp <= type(^end_of_day, :naive_datetime) and
            at.end_stamp >= type(^start_of_day, :naive_datetime) and
            not is_nil(at.end_stamp)
      )

    Repo.one(query)
  end

  @doc """
  Gets a count of all open timers.

  An open timer is one without an end datetime stamp recorded, as well as
  a starting one.
  """
  @spec get_open_timer_count() :: integer()
  def get_open_timer_count() do
    query =
      from(
        at in "timers",
        select: count(at.id),
        where:
          not is_nil(at.start_stamp) and
            is_nil(at.end_stamp)
      )

    Repo.one(query)
  end

  @doc """
  Gets a sum of timer durations for the specified date, by time unit.

  A closed timer is one which has an end datetime stamp recorded, as well as
  a starting one.
  """
  @spec get_closed_timer_durations_for_date(NaiveDateTime.t()) ::
          [{integer, bitstring()}, ...] | []
  def get_closed_timer_durations_for_date(date) when is_struct(date, NaiveDateTime) do
    start_of_day = NaiveDateTime.beginning_of_day(date)
    end_of_day = NaiveDateTime.add(start_of_day, 24, :hour)

    query =
      from(
        at in "timers",
        select: {sum(at.duration), at.duration_time_unit},
        group_by: at.duration_time_unit,
        where:
          at.start_stamp <= type(^end_of_day, :naive_datetime) and
            at.end_stamp >= type(^start_of_day, :naive_datetime) and
            not is_nil(at.end_stamp)
      )

    Repo.all(query)
  end

  @doc """
  Gets a sum of timer durations for the specified project, by time unit.

  A closed timer is one which has an end datetime stamp recorded, as well as
  a starting one.
  """
  @spec get_closed_timer_durations_for_project(bitstring()) ::
          [{integer, bitstring()}, ...] | []
  def get_closed_timer_durations_for_project(project_id)
      when is_bitstring(project_id) do
    query =
      from(
        at in "timers",
        select: {sum(at.duration), at.duration_time_unit},
        group_by: at.duration_time_unit,
        where:
          not is_nil(at.start_stamp) and
            not is_nil(at.end_stamp) and
            at.project_id == ^project_id
      )

    Repo.all(query)
  end

  @doc """
  Gets a list of all open timers.

  A timer is considered open if it has no `end_stamp`.
  """
  @spec get_all_open_timers() :: [Klepsidra.TimeTracking.Timer.t(), ...] | []
  def get_all_open_timers() do
    query =
      from(
        at in Timer,
        left_join: bp in assoc(at, :business_partner),
        left_join: p in assoc(at, :project),
        select: %{
          id: at.id,
          start_stamp: at.start_stamp,
          end_stamp: at.end_stamp,
          duration: at.duration,
          duration_time_unit: at.duration_time_unit,
          description: at.description |> coalesce(""),
          project_name: p.name |> coalesce(""),
          business_partner_id: at.business_partner_id,
          business_partner_name: bp.name |> coalesce(""),
          inserted_at: at.inserted_at
        },
        where:
          not is_nil(at.start_stamp) and
            is_nil(at.end_stamp),
        order_by: [desc: at.start_stamp, desc: at.inserted_at]
      )

    query
    |> Repo.all()
    |> Enum.map(fn rec ->
      Map.merge(rec, %{
        start_stamp:
          Timer.format_human_readable_time!(Timer.parse_html_datetime!(rec.start_stamp)),
        end_stamp: nil,
        formatted_start_date:
          Timex.from_now(
            Timer.parse_html_datetime!(rec.start_stamp),
            NaiveDateTime.local_now()
          ),
        summary:
          rec.description
          |> to_string()
          |> markdown_to_html()
          |> Phoenix.HTML.raw()
      })
    end)
  end

  @doc """
  Creates a timer.

  ## Examples

      iex> create_timer(%{field: value})
      {:ok, %Timer{}}

      iex> create_timer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_timer(attrs \\ %{}) do
    %Timer{}
    |> Timer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a timer.

  ## Examples

      iex> update_timer(timer, %{field: new_value})
      {:ok, %Timer{}}

      iex> update_timer(timer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_timer(%Timer{} = timer, attrs) do
    timer
    |> Timer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a timer.

  ## Examples

      iex> delete_timer(timer)
      {:ok, %Timer{}}

      iex> delete_timer(timer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_timer(%Timer{} = timer) do
    Repo.delete(timer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking timer changes.

  ## Examples

      iex> change_timer(timer)
      %Ecto.Changeset{data: %Timer{}}

  """
  def change_timer(%Timer{} = timer, attrs \\ %{}) do
    Timer.changeset(timer, attrs)
  end

  @doc """
  Returns the list of notes.

  ## Examples

      iex> list_notes()
      [%Note{}, ...]

  """
  def list_notes do
    Repo.all(Note)
  end

  @doc """
  Returns a list of notes matching the given `filter`.

  Example filter:

  %{timer_id: 42}
  """
  def list_notes(filter) when is_map(filter) do
    # from(Note)
    # |> filter_notes_by_timer(filter)
    # |> Repo.all()
  end

  @doc """
  Gets a single note.

  Raises `Ecto.NoResultsError` if the Note does not exist.

  ## Examples

      iex> get_note!(123)
      %Note{}

      iex> get_note!(456)
      ** (Ecto.NoResultsError)

  """
  def get_note!(id), do: Repo.get!(Note, id)

  @doc false
  def get_note_by_timer_id!(timer_id) do
    Note
    |> where(timer_id: ^timer_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @doc """
  Creates a note.

  ## Examples

      iex> create_note(%{field: value})
      {:ok, %Note{}}

      iex> create_note(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_note(attrs \\ %{}) do
    %Note{}
    |> Note.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a note.

  ## Examples

      iex> update_note(note, %{field: new_value})
      {:ok, %Note{}}

      iex> update_note(note, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_note(%Note{} = note, attrs) do
    note
    |> Note.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a note.

  ## Examples

      iex> delete_note(note)
      {:ok, %Note{}}

      iex> delete_note(note)
      {:error, %Ecto.Changeset{}}

  """
  def delete_note(%Note{} = note) do
    Repo.delete(note)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking note changes.

  ## Examples

      iex> change_note(note)
      %Ecto.Changeset{data: %Note{}}

  """
  def change_note(%Note{} = note, attrs \\ %{}) do
    Note.changeset(note, attrs)
  end

  @doc """
  Returns the list of activity_types.

  ## Examples

      iex> list_activity_types()
      [%ActivityType{}, ...]

  """
  def list_activity_types do
    ActivityType |> order_by(asc: fragment("name COLLATE NOCASE")) |> Repo.all()
  end

  @doc """
  Returns the list of active activity_types.

  ## Examples

      iex> list_active_activity_types()
      [%ActivityType{}, ...]

  """
  def list_active_activity_types do
    ActivityType
    |> where(active: true)
    |> order_by(asc: fragment("name COLLATE NOCASE"))
    |> Repo.all()
  end

  @doc """
  Gets a single activity_type.

  Raises `Ecto.NoResultsError` if the Activity type does not exist.

  ## Examples

      iex> get_activity_type!(123)
      %ActivityType{}

      iex> get_activity_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_activity_type!(id), do: Repo.get!(ActivityType, id)

  @doc """
  Creates a activity_type.

  ## Examples

      iex> create_activity_type(%{field: value})
      {:ok, %ActivityType{}}

      iex> create_activity_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_activity_type(attrs \\ %{}) do
    %ActivityType{}
    |> ActivityType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a activity_type.

  ## Examples

      iex> update_activity_type(activity_type, %{field: new_value})
      {:ok, %ActivityType{}}

      iex> update_activity_type(activity_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_activity_type(%ActivityType{} = activity_type, attrs) do
    activity_type
    |> ActivityType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a activity_type.

  ## Examples

      iex> delete_activity_type(activity_type)
      {:ok, %ActivityType{}}

      iex> delete_activity_type(activity_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_activity_type(%ActivityType{} = activity_type) do
    Repo.delete(activity_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking activity_type changes.

  ## Examples

      iex> change_activity_type(activity_type)
      %Ecto.Changeset{data: %ActivityType{}}

  """
  def change_activity_type(%ActivityType{} = activity_type, attrs \\ %{}) do
    ActivityType.changeset(activity_type, attrs)
  end
end
