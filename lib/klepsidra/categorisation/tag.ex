defmodule Klepsidra.Categorisation.Tag do
  @moduledoc """
  Defines a schema for the `Tags` entity, used for categorising timed activities
  with free form tags.

  To provide a helpful flourish which will make selected tags stand out, we include a
  `colour` field.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Klepsidra.Categorisation.TimerTags

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

    timestamps()

    many_to_many(:timers, TimerTags, join_through: "timer_tags")
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
  Find tag list differences.
  """
  @spec tag_list_diff(list1 :: [Ecto.UUID.t(), ...], list2 :: [Ecto.UUID.t(), ...]) :: list()
  def tag_list_diff(list1, list2) when is_list(list1) and is_list(list2) do
    List.myers_difference(list1, list2)
  end

  def handle_tag_list_changes(list1, list2, base_entity, insert_function, delete_function)
      when is_list(list1) and is_list(list2) and is_struct(base_entity) and
             is_function(insert_function) and
             is_function(delete_function) do
    myers_difference = tag_list_diff(list1, list2)

    List.keyfind(myers_difference, :ins, 0, [])
    |> handle_tag_actions(base_entity, insert_function)

    List.keyfind(myers_difference, :del, 0, [])
    |> handle_tag_actions(base_entity, delete_function)
  end

  def handle_tag_actions([], _base_entity, _enumeration_function), do: nil

  def handle_tag_actions({:ins, tag_id_list}, base_entity, enumeration_function),
    do: handle_tag_actions(tag_id_list, base_entity, enumeration_function)

  def handle_tag_actions({:del, tag_id_list}, base_entity, enumeration_function),
    do: handle_tag_actions(tag_id_list, base_entity, enumeration_function)

  def handle_tag_actions(tag_id_list, base_entity, enumeration_function)
      when is_list(tag_id_list) and is_function(enumeration_function) do
    enumeration_function.(base_entity, tag_id_list)
  end

  def handle_tag_actions(_, _base_entity, _enumeration_function), do: nil

  def sort_tags(timer_tags) do
    Enum.sort_by(timer_tags, fn timer_tag -> timer_tag.tag.name end)
  end
end
