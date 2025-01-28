defmodule Klepsidra.TimeTracking do
  @moduledoc """
  The TimeTracking context.
  """

  import Ecto.Query, warn: false
  alias Klepsidra.Math
  alias Klepsidra.Repo
  alias Klepsidra.TimeTracking.ActivityType
  alias Klepsidra.TimeTracking.Note
  alias Klepsidra.TimeTracking.Timer

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
  Deletes an activity_type.

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

  @typedoc """
  The `timer_record.t()` type is a list of the fields and data types returned in
  timer record queries.
  """
  @type timer_record :: %{
          id: binary(),
          start_stamp: binary(),
          end_stamp: binary(),
          duration: integer(),
          duration_time_unit: binary(),
          project_id: nil | binary(),
          project_name: binary(),
          business_partner_id: nil | binary(),
          business_partner_name: binary(),
          billable: boolean(),
          billing_duration: integer(),
          billing_duration_time_unit: binary(),
          billing_rate: Decimal.t(),
          activity_type_id: nil | binary(),
          activity_type: binary(),
          description: binary(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t(),
          modified: integer()
        }

  @typedoc """
  The `duration.t()` type is a map containing a time duration in several formats:

  * The duration as a `Cldr.Unit.t()` type, denominated in the base time increment, `:second`
  * The duration in hours, a basic major unit of the day
  * A human-readable string representing the time converted to days, hours and minutes,
    or nil
  """
  @type duration :: %{
          base_unit_duration: Cldr.Unit.t(),
          duration_in_hours: bitstring(),
          human_readable_duration: bitstring() | nil
        }

  @typedoc """
  When filtering timer queries, a `timer_filter.t()` filter structure will be passed
  with criteria to filter by. The type specifies those fields and their types.
  """
  @type timer_filter :: %{
          from: bitstring(),
          to: bitstring(),
          project_id: bitstring(),
          business_partner_id: bitstring(),
          activity_type_id: bitstring(),
          billable: bitstring(),
          modified: binary() | integer()
        }

  @spec list_timers(filter :: timer_filter()) :: [map(), ...]
  @doc """
  Returns a list of timers, filtered by criteria in the `filter`
  parameter.

  ## Examples

      iex> list_timers(%{from: "", to: "", project_id: "", business_partner_id: "90bc20d3-be65-46ea-a579-453d6ae3d378", activity_type_id: "", billable: "", modified: ""})
      [%{...}]
  """
  def list_timers(%{modified: modified} = filter) when is_map(filter) do
    list_timers_query(filter)
    |> filter_by_modification_status(%{modified: modified})
    |> Repo.all()
  end

  @doc """

  ## Examples

      iex> list_timers_with_statistics(%{from: "", to: "", project_id: "", business_partner_id: "90bc20d3-be65-46ea-a579-453d6ae3d378", activity_type_id: "", billable: "", modified: ""})
      %{meta: %{
          aggregate_duration: %{
            duration_in_hours: "4.2 hours",
            base_unit_duration: Cldr.Unit.new!(:second, 15120),
            human_readable_duration: nil},
          aggregate_billing_duration: %{
            duration_in_hours: "5.3 hours",
            base_unit_duration: Cldr.Unit.new!(:second, 18900),
            human_readable_duration: nil}},
          timer_list: [%{...}, ...]}
  """
  @spec list_timers_with_statistics(filter :: timer_filter()) :: %{
          timer_list: [map(), ...],
          meta: %{
            timer_count: non_neg_integer(),
            aggregate_duration: duration(),
            average_timer_duration: duration(),
            aggregate_billing_duration: duration()
          }
        }
  def list_timers_with_statistics(filter) when is_map(filter) do
    timer_count = list_timers_count(filter)
    timer_duration = list_timers_aggregate_duration(filter)

    average_timer_duration =
      Math.arithmetic_mean(timer_duration.base_unit_duration, timer_count)
      |> Timer.format_aggregate_duration_for_project()

    %{
      timer_list: list_timers(filter),
      meta: %{
        timer_count: timer_count,
        aggregate_duration: timer_duration,
        average_timer_duration: average_timer_duration,
        aggregate_billing_duration: list_timers_aggregate_billing_duration(filter)
      }
    }
  end

  @doc """

  ## Examples

      iex> list_timers_count(%{from: "", to: "", project_id: "", business_partner_id: "90bc20d3-be65-46ea-a579-453d6ae3d378", activity_type_id: "", billable: "", modified: ""})
      9
  """
  @spec list_timers_count(filter :: timer_filter()) :: non_neg_integer()
  def list_timers_count(%{modified: modified} = filter) when is_map(filter) do
    list_timers_query(filter)
    |> filter_by_modification_status(%{modified: modified})
    |> select([at], count(at.id))
    |> Repo.one()
  end

  @doc """

  ## Examples

      iex> list_timers_aggregate_duration(%{from: "", to: "", project_id: "", business_partner_id: "90bc20d3-be65-46ea-a579-453d6ae3d378", activity_type_id: "", billable: "", modified: ""})
      %{
        duration_in_hours: "4.2 hours",
        base_unit_duration: Cldr.Unit.new!(:second, 15120),
        human_readable_duration: nil
      }
  """
  @spec list_timers_aggregate_duration(filter :: timer_filter()) :: duration()
  def list_timers_aggregate_duration(filter) when is_map(filter) do
    list_timers_query(filter)
    |> select([at], {sum(at.duration), at.duration_time_unit})
    |> group_by([at], at.duration_time_unit)
    |> Repo.all()
    |> Timer.calculate_aggregate_duration_for_timers()
  end

  @doc """

  ## Examples

      iex> list_timers_aggregate_billing_duration(%{from: "", to: "", project_id: "", business_partner_id: "90bc20d3-be65-46ea-a579-453d6ae3d378", activity_type_id: "", billable: "", modified: ""})
      %{
        duration_in_hours: "5.3 hours",
        base_unit_duration: Cldr.Unit.new!(:second, 18900),
        human_readable_duration: nil
      }
  """
  @spec list_timers_aggregate_billing_duration(filter :: timer_filter()) :: %{
          base_unit_duration: Cldr.Unit.t(),
          duration_in_hours: bitstring(),
          human_readable_duration: bitstring() | nil
        }
  def list_timers_aggregate_billing_duration(filter) when is_map(filter) do
    list_timers_query(filter)
    |> select([at], {sum(at.billing_duration), at.billing_duration_time_unit})
    |> group_by([at], at.billing_duration_time_unit)
    |> Repo.all()
    |> Timer.calculate_aggregate_duration_for_timers()
  end

  @spec list_timers_query(filter :: timer_filter()) :: map()
  defp list_timers_query(filter) when is_map(filter) do
    %{
      from: from,
      to: to,
      project_id: project_id,
      business_partner_id: business_partner_id,
      activity_type_id: activity_type_id,
      billable: billable
    } =
      filter

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

    timer_subquery =
      query
      |> filter_by_date(%{from: from, to: to})
      |> filter_by_project_id(%{project_id: project_id})
      |> filter_by_business_partner_id(%{business_partner_id: business_partner_id})
      |> filter_by_activity_type_id(%{activity_type_id: activity_type_id})
      |> filter_by_billable(%{billable: billable})

    from(at in subquery(timer_subquery))
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
  @spec get_formatted_timer_record!(id :: Ecto.UUID.t(), date :: Date.t()) ::
          %{
            end_stamp: nil | binary(),
            formatted_duration: nil | String.t(),
            formatted_start_date: binary(),
            start_stamp: binary(),
            summary: {:safe, any()},
            description: binary() | [binary()],
            duration: integer(),
            duration_time_unit: binary()
          }
  def get_formatted_timer_record!(id, date) when is_struct(date, Date) do
    from_timers()
    |> filter_timers_matching_id(id)
    |> join_bp_and_project()
    |> join_timers_with_activity_type()
    |> join_timers_with_tags()
    |> select_timer_columns_expanded_with_tags()
    |> Repo.one()
    |> format_timer_fields_single_timer(date)
  end

  @doc """
  Query composition function, equivalent to the SQL `FROM` statement,
  a starting point in the timer query pipeline, selecting _from_
  the timers table.
  """
  @spec from_timers() :: Ecto.Query.t()
  def from_timers() do
    from(t in Timer, as: :timers)
  end

  @doc """
  Query composition function, equivalent to the SQL `WHERE` statement, filtering
  for timers matching desired timer `ID` only.
  """
  @spec filter_timers_matching_id(query :: Ecto.Query.t(), id :: Ecto.UUID.t()) :: Ecto.Query.t()
  def filter_timers_matching_id(query, id) do
    from [timers: t] in query,
      where: t.id == ^id
  end

  @doc """
  Query composition function, equivalent to the SQL `WHERE` statement, filtering
  for closed timers only.

  Strictly speaking, closed timers are those with non-nil start and end stamps.
  """
  @spec filter_timers_closed_only(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def filter_timers_closed_only(query) do
    from [timers: t] in query,
      where:
        not is_nil(t.start_stamp) and
          not is_nil(t.end_stamp)
  end

  @doc """
  Query composition function, equivalent to the SQL `WHERE` statement, filtering
  for closed timers for a given date.

  In this context, a closed timer is one with a non-nil start stamp starting on the
  given date, and a non-nil end stamp ending on or after the date.
  """
  @spec filter_timers_closed_only_for_date(query :: Ecto.Query.t(), date :: Date.t()) ::
          Ecto.Query.t()
  def filter_timers_closed_only_for_date(query, date) do
    next_day = Date.add(date, 1)

    from [timers: t] in query,
      where:
        t.start_stamp < type(^next_day, :date) and
          not is_nil(t.end_stamp) and
          t.end_stamp >= type(^date, :date)
  end

  @doc """
  Query composition function, equivalent to the SQL `WHERE` statement, filtering
  for open timers only.

  Open timers have a non-nil start stamp and a `nil` end stamp.
  """
  @spec filter_timers_open_only(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def filter_timers_open_only(query) do
    from [timers: t] in query,
      where:
        not is_nil(t.start_stamp) and
          is_nil(t.end_stamp)
  end

  @doc """
  Query composition function, equivalent to the SQL `WHERE` statement, filtering
  for all timers falling on the provided date.
  """
  @spec filter_timers_by_date(query :: Ecto.Query.t(), date :: Date.t()) :: Ecto.Query.t()
  def filter_timers_by_date(query, date) do
    next_day = Date.add(date, 1)

    from [timers: t] in query,
      where:
        is_nil(t.end_stamp) or
          fragment("? BETWEEN ? AND ?", t.end_stamp, ^date, ^next_day)
  end

  @doc """
  Query composition function, equivalent to the SQL `WHERE` statement, filtering
  for all non-nil tag `ID`s.
  """
  @spec filter_timers_with_non_nil_tag_id(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def filter_timers_with_non_nil_tag_id(query) do
    from [tags: tag] in query,
      where: not is_nil(tag.id)
  end

  @doc """
  Query composition function, equivalent to the SQL `WHERE` statement, filtering
  for timers assigned to a project.
  """
  @spec filter_timers_by_project(query :: Ecto.Query.t(), project_id :: Ecto.UUID.t()) ::
          Ecto.Query.t()
  def filter_timers_by_project(query, project_id) do
    from [timers: t] in query,
      where: t.project_id == ^project_id
  end

  @doc """
  Query composition function, equivalent to the SQL `ORDER BY` statement, sorting
  timers by their inserted_at date and time stamp, in descending order.
  """
  @spec order_timers_inserted_desc_id_asc(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def order_timers_inserted_desc_id_asc(query) do
    from [timers: t] in query,
      order_by: [desc: t.inserted_at, asc: t.id]
  end

  @doc """
  Query composition function, equivalent to the SQL `JOIN` statement, joining
  the base timer table to the activity types table using an inner join.
  """
  @spec join_timers_with_activity_type(query :: Ecto.Query.t()) ::
          Ecto.Query.t()
  def join_timers_with_activity_type(query) do
    from [timers: t] in query,
      left_join: ac_t in assoc(t, :activity_type),
      as: :activity_type
  end

  @doc """
  Query composition function, equivalent to the SQL `JOIN` statement, joining
  the base timer table to the business partners table using an inner join.
  """
  @spec join_timers_with_bp(query :: Ecto.Query.t()) ::
          Ecto.Query.t()
  def join_timers_with_bp(query) do
    from [timers: t] in query,
      left_join: bp in assoc(t, :business_partner),
      as: :business_partners
  end

  @doc """
  Query composition function, equivalent to the SQL `JOIN` statement, joining
  the base timer table to the business partners and projects tables using an
  inner join.
  """
  @spec join_bp_and_project(query :: Ecto.Query.t()) ::
          Ecto.Query.t()
  def join_bp_and_project(query) do
    from [timers: t] in query,
      left_join: bp in assoc(t, :business_partner),
      as: :business_partners,
      left_join: p in assoc(t, :project),
      as: :projects
  end

  @doc """
  Query composition function, equivalent to the SQL `JOIN` statement, joining
  the base timer table to the tags table using an inner join.
  """
  @spec join_timers_with_tags(query :: Ecto.Query.t()) ::
          Ecto.Query.t()
  def join_timers_with_tags(query) do
    from [timers: t] in query,
      left_join: tag in assoc(t, :tags),
      as: :tags
  end

  @doc """
  Query composition function, equivalent to the SQL `SELECT` statement, defining
  a map of fields to be returned from the query.

  Note the use of the coalesce() function, ensuring that any `nil` values are
  converted to empty strings.
  """
  @spec select_timer_columns(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def select_timer_columns(query) do
    from [timers: t, business_partners: bp, projects: p] in query,
      select: %{
        id: t.id,
        start_stamp: t.start_stamp,
        end_stamp: t.end_stamp,
        duration: t.duration,
        duration_time_unit: t.duration_time_unit,
        description: t.description |> coalesce(""),
        project_name: p.name |> coalesce(""),
        business_partner_name: bp.name |> coalesce(""),
        inserted_at: t.inserted_at
      }
  end

  @doc """
  Query composition function, equivalent to the SQL `SELECT` statement, defining
  a map of fields to be returned from the query, including aggregated tag fields.

  Note the use of the coalesce() function, ensuring that any `nil` values are
  converted to empty strings.
  """
  @spec select_timer_columns_with_tags(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def select_timer_columns_with_tags(query) do
    from [timers: t, business_partners: bp, projects: p, tags: tag] in query,
      select: %{
        id: t.id,
        start_stamp: t.start_stamp,
        end_stamp: t.end_stamp,
        duration: t.duration,
        duration_time_unit: t.duration_time_unit,
        description: t.description |> coalesce(""),
        project_name: p.name |> coalesce(""),
        business_partner_name: bp.name |> coalesce(""),
        inserted_at: t.inserted_at,
        tags:
          fragment(
            "JSON_GROUP_ARRAY(CASE WHEN ? IS NOT NULL THEN JSON_OBJECT('id', ?, 'name', ?, 'bg_colour', ?, 'fg_colour', ?) END)",
            tag.id,
            tag.id,
            tag.name,
            tag.colour,
            tag.fg_colour
          )
      }
  end

  @doc """
  Query composition function, equivalent to the SQL `SELECT` statement, defining
  an expanded map of fields to be returned from the query.

  Note the use of the `coalesce()` function, ensuring that any `nil` values are
  converted to empty strings.
  """
  @spec select_timer_columns_expanded(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def select_timer_columns_expanded(query) do
    from [timers: t, business_partners: bp, projects: p, activity_type: ac_t] in query,
      select: %{
        id: t.id,
        start_stamp: t.start_stamp,
        end_stamp: t.end_stamp,
        duration: t.duration,
        duration_time_unit: t.duration_time_unit,
        description: t.description |> coalesce(""),
        project_id: p.id,
        project_name: p.name |> coalesce(""),
        business_partner_id: t.business_partner_id,
        business_partner_name: bp.name |> coalesce(""),
        activity_type_id: ac_t.id,
        activity_type: ac_t.name |> coalesce(""),
        billable: t.billable,
        billing_duration: t.billing_duration,
        billing_duration_time_unit: t.billing_duration_time_unit,
        billing_rate: t.billing_rate,
        inserted_at: t.inserted_at
      }
  end

  @doc """
  Query composition function, equivalent to the SQL `SELECT` statement, defining
  an expanded map of fields to be returned from the query, along with an aggregated
  tag field.

  Note the use of the `coalesce()` function, ensuring that any `nil` values are
  converted to empty strings.
  """
  @spec select_timer_columns_expanded_with_tags(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def select_timer_columns_expanded_with_tags(query) do
    from [timers: t, business_partners: bp, projects: p, activity_type: ac_t, tags: tag] in query,
      select: %{
        id: t.id,
        start_stamp: t.start_stamp,
        end_stamp: t.end_stamp,
        duration: t.duration,
        duration_time_unit: t.duration_time_unit,
        description: t.description |> coalesce(""),
        project_id: p.id,
        project_name: p.name |> coalesce(""),
        business_partner_id: t.business_partner_id,
        business_partner_name: bp.name |> coalesce(""),
        activity_type_id: ac_t.id,
        activity_type: ac_t.name |> coalesce(""),
        tags:
          fragment(
            "JSON_GROUP_ARRAY(CASE WHEN ? IS NOT NULL THEN JSON_OBJECT('id', ?, 'name', ?, 'bg_colour', ?, 'fg_colour', ?) END)",
            tag.id,
            tag.id,
            tag.name,
            tag.colour,
            tag.fg_colour
          ),
        billable: t.billable,
        billing_duration: t.billing_duration,
        billing_duration_time_unit: t.billing_duration_time_unit,
        billing_rate: t.billing_rate,
        inserted_at: t.inserted_at
      }
  end

  @doc """
  Query composition function, equivalent to the SQL `SELECT` statement, returning
  a list of desired tag fields.
  """
  @spec select_timer_tags(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def select_timer_tags(query) do
    from [tags: tag] in query,
      select: %{
        id: tag.id,
        name: tag.name,
        bg_colour: tag.colour,
        fg_colour: tag.fg_colour
      }
  end

  @doc """
  Query composition function, equivalent to the SQL `SELECT` statement, returning
  a timer count only.
  """
  @spec select_timer_count(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def select_timer_count(query) do
    from [timers: t] in query,
      select: count(t.id)
  end

  @doc """
  Query composition function, equivalent to the SQL `SELECT` statement, returning
  a sum of timer durations.
  """
  @spec select_timer_duration_sum(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def select_timer_duration_sum(query) do
    from [timers: t] in query,
      select: {sum(t.duration), t.duration_time_unit}
  end

  @doc """
  Query composition function, equivalent to the SQL `GROUP BY` statement, ensuring
  that records returned by the `SELECT` statement are grouped by the timer `ID`.
  """
  @spec group_timer_columns_by_timer_id(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def group_timer_columns_by_timer_id(query) do
    from [timers: t] in query,
      group_by: t.id
  end

  @doc """
  Query composition function, equivalent to the SQL `GROUP BY` statement, ensuring
  that records returned by the `SELECT` statement are grouped by tag `ID`s.
  """
  @spec group_timers_by_tag_id(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def group_timers_by_tag_id(query) do
    from [tags: tag] in query,
      group_by: tag.id
  end

  @doc """
  Query composition function, equivalent to the SQL `GROUP BY` statement, ensuring
  that records returned by the `SELECT` statement are grouped by the duration time
  unit.
  """
  @spec group_timer_columns_by_duration_time_unit(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def group_timer_columns_by_duration_time_unit(query) do
    from [timers: t] in query,
      group_by: t.duration_time_unit
  end

  @doc """
  Post-query formatting function for a timer list, converting timestamps to a
  human-readable time format only, formatting the start date as relative to
  the current time, formatting the duration in user-friendly time units.
  """
  @spec format_timer_fields(timer_list :: [map(), ...] | [], date :: Date.t()) ::
          [map(), ...] | []
  def format_timer_fields(timer_list, date) when is_list(timer_list) do
    Enum.map(timer_list, fn timer -> format_timer_fields_single_timer(timer, date) end)
  end

  @doc """
  Post-query formatting function for a single timer, converting the timestamps
  to a human-readable time format only, formatting the start date as relative
  to the current time, formatting the duration in user-friendly time units.

  Note if the individual timer record has a `tags` key, then it is expected to
  be in pure JSON format, and will be converted to a map structure.
  """
  @spec format_timer_fields_single_timer(timer :: map() | nil, date :: Date.t()) ::
          map()
  def format_timer_fields_single_timer(%{tags: tags} = timer, date) do
    Map.merge(timer, %{
      start_stamp:
        Timer.format_human_readable_time!(Timer.parse_html_datetime!(timer.start_stamp)),
      end_stamp:
        if(timer.end_stamp,
          do: Timer.format_human_readable_time!(Timer.parse_html_datetime!(timer.end_stamp))
        ),
      summary:
        timer.description
        |> markdown_to_html()
        |> Phoenix.HTML.raw(),
      formatted_start_date:
        if(
          Date.compare(Timer.parse_html_datetime!(timer.start_stamp), date) ==
            :lt,
          do: "Started yesterday",
          else: ""
        ),
      formatted_duration:
        {timer.duration, timer.duration_time_unit}
        |> Timer.convert_duration_to_base_time_unit()
        |> Klepsidra.TimeTracking.Timer.format_human_readable_duration(),
      tags: Jason.decode!(tags)
    })
  end

  def format_timer_fields_single_timer(timer, date) do
    Map.merge(timer, %{
      start_stamp:
        Timer.format_human_readable_time!(Timer.parse_html_datetime!(timer.start_stamp)),
      end_stamp:
        if(timer.end_stamp,
          do: Timer.format_human_readable_time!(Timer.parse_html_datetime!(timer.end_stamp))
        ),
      summary:
        timer.description
        |> markdown_to_html()
        |> Phoenix.HTML.raw(),
      formatted_start_date:
        if(
          Date.compare(Timer.parse_html_datetime!(timer.start_stamp), date) ==
            :lt,
          do: "Started yesterday",
          else: ""
        ),
      formatted_duration:
        {timer.duration, timer.duration_time_unit}
        |> Timer.convert_duration_to_base_time_unit()
        |> Klepsidra.TimeTracking.Timer.format_human_readable_duration()
    })
  end

  @doc """
  Returns the list of timers, with `business_partner`, `project`,
  `activity_type` and `tags` associations.

  ## Examples

      iex> list_timers(~D[2025-01-11])
      [%{}, ...]

  """
  @spec list_all_timers(date :: Date.t()) :: [map(), ...]
  def list_all_timers(date) do
    from_timers()
    |> order_timers_inserted_desc_id_asc()
    |> join_bp_and_project()
    |> join_timers_with_activity_type()
    |> join_timers_with_tags()
    |> select_timer_columns_expanded_with_tags()
    |> group_timer_columns_by_timer_id()
    |> Repo.all()
    |> format_timer_fields(date)
  end

  @doc """
  Gets a list of all timers for the specified date.
  """
  @spec list_all_timer_tags_for_date(date :: Date.t()) :: [map(), ...]
  def list_all_timer_tags_for_date(date) when is_struct(date, Date) do
    from_timers()
    |> join_timers_with_tags()
    |> filter_timers_by_date(date)
    |> filter_timers_with_non_nil_tag_id()
    |> select_timer_tags()
    |> group_timers_by_tag_id()
    |> Repo.all()
  end

  @doc """
  Gets a list of all open timers.

  A timer is considered open if it has no `end_stamp`.
  """
  @spec list_all_open_timers(date :: Date.t()) :: [Klepsidra.TimeTracking.Timer.t(), ...] | []
  def list_all_open_timers(date) do
    from_timers()
    |> filter_timers_open_only()
    |> order_timers_inserted_desc_id_asc()
    |> join_bp_and_project()
    |> join_timers_with_tags()
    |> select_timer_columns_with_tags()
    |> group_timer_columns_by_timer_id()
    |> Repo.all()
    |> format_timer_fields(date)
  end

  @doc """
  Gets a list of closed timers started on the specified date.

  A closed timer is one which has an end datetime stamp recorded, as well as
  a starting one.
  """
  @spec list_closed_timers_for_date(date :: Date.t()) ::
          [map(), ...] | []
  def list_closed_timers_for_date(date) when is_struct(date, Date) do
    from_timers()
    |> filter_timers_closed_only_for_date(date)
    |> order_timers_inserted_desc_id_asc()
    |> join_bp_and_project()
    |> join_timers_with_tags()
    |> select_timer_columns_with_tags()
    |> group_timer_columns_by_timer_id()
    |> Repo.all()
    |> format_timer_fields(date)
  end

  @doc """
  Gets a count of closed timers started on the specified date.

  A closed timer is one which has an end datetime stamp recorded, as well as
  a starting one.
  """
  @spec get_closed_timer_count_for_date(Date.t()) :: integer()
  def get_closed_timer_count_for_date(date) when is_struct(date, Date) do
    from_timers()
    |> filter_timers_closed_only_for_date(date)
    |> select_timer_count()
    |> Repo.one()
  end

  @doc """
  Gets a count of all open timers.

  An open timer is one without an end datetime stamp recorded, as well as
  a starting one.
  """
  @spec get_open_timer_count() :: integer()
  def get_open_timer_count() do
    from_timers()
    |> filter_timers_open_only()
    |> select_timer_count()
    |> Repo.one()
  end

  @doc """
  Gets a sum of timer durations for the specified date, by time unit.

  A closed timer is one which has an end datetime stamp recorded, as well as
  a starting one.
  """
  @spec get_closed_timer_durations_for_date(date :: Date.t()) ::
          [{integer, bitstring()}, ...] | []
  def get_closed_timer_durations_for_date(date) when is_struct(date, Date) do
    from_timers()
    |> filter_timers_closed_only_for_date(date)
    |> select_timer_duration_sum()
    |> group_timer_columns_by_duration_time_unit()
    |> Repo.all()
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
    from_timers()
    |> filter_timers_closed_only()
    |> filter_timers_by_project(project_id)
    |> select_timer_duration_sum()
    |> group_timer_columns_by_duration_time_unit()
    |> Repo.all()
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
  @spec get_note_by_timer_id!(timer_id :: Ecto.UUID.t()) :: Klepsidra.TimeTracking.Note.t() | []
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
end
