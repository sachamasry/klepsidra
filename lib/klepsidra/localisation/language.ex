defmodule Klepsidra.Localisation.Language do
  @moduledoc """
  Defines a schema for the `Languages` entity, listing the languages of the world.

  This is not meant to be a user-editable entity, imported on a periodic basis
  from the [Geonames](https://geonames.org) project, specifically the
  `iso-languagecodes.txt` file, all languages' information, with the file
  annotation headers stripped off and column headers converted to lowercase,
  underscore-separated names.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @type t :: %__MODULE__{
          "iso_639-1": String.t(),
          "iso_639-2": String.t(),
          "iso_639-3": String.t(),
          language_name: String.t()
        }
  schema "localisation_languages" do
    field(:"iso_639-3", :string, primary_key: true)
    field(:"iso_639-2", :string)
    field(:"iso_639-1", :string)
    field(:language_name, :string)

    timestamps()
  end

  @doc false
  def changeset(language, attrs) do
    language
    |> cast(attrs, [:"iso_639-3", :"iso_639-2", :"iso_639-1", :language_name])
    |> validate_required([:"iso_639-3", :language_name])
  end
end
