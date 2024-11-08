defmodule Klepsidra.DynamicCSS do
  @moduledoc """
  Generate CSS content based on your dynamic data (such as
  tag colors), saving it to a `.css` file in the `priv/static/assets`
  directory.
  """

  alias Klepsidra.Categorisation

  @doc """
  Generates tag styling classes for all tags, named `tag-<tag_name>`.
  """
  @spec generate_tag_styles(tags :: [Klepsidra.Categorisation.Tag.t(), ...] | []) :: binary()
  def generate_tag_styles(tags) do
    Enum.map_join(tags, "\n", fn tag ->
      generate_tag_style_declaration(tag)
    end)
  end

  @doc """
  Generates a single tag style declaration.
  """
  @spec generate_tag_style_declaration(tag :: Klepsidra.Categorisation.Tag.t()) :: binary()
  def generate_tag_style_declaration(tag) when is_bitstring(tag),
    do: generate_tag_style_declaration(Categorisation.get_tag!(tag))

  def generate_tag_style_declaration(tag) when is_struct(tag, Klepsidra.Categorisation.Tag) do
    tag_class_name = convert_tag_name_to_class(tag.name)

    fg_colour = if tag.fg_colour, do: tag.fg_colour, else: "#fff"

    bg_colour = if tag.colour, do: tag.colour, else: "rgb(148, 163, 184)"

    bg_colour_lowered_opacity =
      if tag.colour, do: tag.colour <> "88", else: "rgba(255, 255, 255, 0.1)"

    """
    .tag-#{tag_class_name}, .tag-#{tag_class_name} + button {background-color: #{bg_colour}; color: #{fg_colour};}
    .tag-#{tag_class_name} + button {border-left: 2px solid #{bg_colour_lowered_opacity}; border-left-color: oklch(from #{bg_colour} calc(l + 0.1) c h);}
    """
  end

  @doc """
  Converts tag names to CSS class-compliant format.
  """
  @spec convert_tag_name_to_class(tag_name :: binary()) :: binary()
  def convert_tag_name_to_class(tag_name) when is_bitstring(tag_name) do
    tag_name
    |> String.split(" ")
    |> Enum.map(fn item ->
      String.replace(
        item,
        [
          "!",
          "£",
          "$",
          "%",
          "^",
          "&",
          "*",
          "(",
          ")",
          "[",
          "]",
          "{",
          "}",
          ":",
          ";",
          "/",
          "\\",
          "<",
          ">"
        ],
        "",
        global: true
      )
    end)
    |> Enum.reject(fn item -> item == "" end)
    |> Enum.join("_")
  end
end
