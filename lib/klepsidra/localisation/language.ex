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
          "iso_639-1_language_code": String.t(),
          "iso_639-2_language_code": String.t(),
          "iso_639-3_language_code": String.t(),
          language_name: String.t()
        }
  schema "localisation_languages" do
    field(:"iso_639-3_language_code", :string, primary_key: true)
    field(:"iso_639-2_language_code", :string)
    field(:"iso_639-1_language_code", :string)
    field(:language_name, :string)

    timestamps()
  end

  @doc false
  def changeset(language, attrs) do
    language
    |> cast(attrs, [
      :"iso_639-3_language_code",
      :"iso_639-2_language_code",
      :"iso_639-1_language_code",
      :language_name
    ])
    |> unique_constraint(:"iso_639-3")
    |> validate_required([:"iso_639-3_language_code", :language_name])
  end
end
