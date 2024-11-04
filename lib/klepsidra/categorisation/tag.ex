defmodule Klepsidra.Categorisation.Tag do
  @moduledoc """
  Defines a schema for the `Tags` entity, used for categorising timed activities
  with free form tags.

  To provide a helpful flourish which will make selected tags stand out, we include a
  `colour` field.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Klepsidra.Categorisation

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          name: String.t(),
          description: String.t(),
          colour: String.t(),
          fg_colour: String.t()
        }
  schema "tags" do
    field(:name, :string)
    field(:description, :string)
    field(:colour, :string)
    field(:fg_colour, :string)

    many_to_many(:timers, Klepsidra.TimeTracking.Timer,
      join_through: "timer_tags",
      on_replace: :delete,
      preload_order: [asc: :start_stamp]
    )

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :description, :colour, :fg_colour])
    |> validate_required([:name], message: "Enter a tag name")
    |> unique_constraint(:name,
      name: :tags_name_index,
      message: "A tag with this name already exists"
    )
  end

  @doc """
  Finds tag list differences between the list of applied tags and
  those in the front-end component's accumulator list, calling 
  functions responsible for adding and removing tags.
  """
  @spec handle_tag_list_changes(list1 :: list(), list2 :: list(), entity_id :: bitstring()) ::
          nil
  def handle_tag_list_changes([], [], _entity_id), do: nil

  def handle_tag_list_changes(_list1, _list2, nil), do: nil

  def handle_tag_list_changes(list1, list2, entity_id)
      when is_list(list1) and is_list(list2) and is_bitstring(entity_id) do
    deletion_list = list1 -- list2
    insertion_list = list2 -- list1

    insert_function = fn entity_id, insertion_list ->
      Categorisation.add_timer_tag(entity_id, insertion_list)
    end

    delete_function = fn entity_id, deletion_list ->
      Categorisation.delete_timer_tag(entity_id, deletion_list)
    end

    handle_tag_actions(insertion_list, entity_id, insert_function)

    handle_tag_actions(deletion_list, entity_id, delete_function)
  end

  @doc """
  """
  @spec handle_tag_actions(
          action_list :: list(),
          entity_id :: bitstring(),
          insert_function :: function()
        ) :: nil | none()
  def handle_tag_actions([], _base_entity, _enumeration_function), do: nil

  def handle_tag_actions({:ins, tag_id_list}, base_entity, enumeration_function),
    do: handle_tag_actions(tag_id_list, base_entity, enumeration_function)

  def handle_tag_actions({:del, tag_id_list}, base_entity, enumeration_function),
    do: handle_tag_actions(tag_id_list, base_entity, enumeration_function)

  def handle_tag_actions(tag_id_list, base_entity, enumeration_function)
      when is_list(tag_id_list) and is_function(enumeration_function) do
    tag_id_list
    |> Enum.map(fn tag_id ->
      enumeration_function.(base_entity, tag_id)
    end)
  end

  def handle_tag_actions(_, _base_entity, _enumeration_function), do: nil
end
