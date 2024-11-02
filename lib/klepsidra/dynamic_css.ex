defmodule Klepsidra.DynamicCSS do
  @moduledoc """
  Generate CSS content based on your dynamic data (such as
  tag colors), saving it to a `.css` file in the `priv/static/assets`
  directory.
  """

  @css_file_path "priv/static/assets/generated_styles.css"

  @doc """
  Generates tag styling classes for all tags, named `tag-<tag_name>`.
  """
  @spec generate_tag_styles(tags :: [Klepsidra.Categorisation.Tag.t(), ...] | []) :: :ok
  def generate_tag_styles(tags) do
    css_content =
      Enum.map_join(tags, "\n", fn tag ->
        tag_class_name = convert_tag_name_to_class(tag.name)

        fg_colour = if tag.fg_colour, do: tag.fg_colour, else: "white"

        bg_colour = if tag.colour, do: tag.colour, else: "rgb(148, 163, 184)"

        bg_colour_lowered_opacity =
          if tag.colour, do: tag.colour <> "88", else: "rgba(255, 255, 255, 0.1)"

        """
        .tag-#{tag_class_name}, .tag-#{tag_class_name} + button {
          background-color: #{bg_colour};
          color: #{fg_colour}
        }

        .tag-#{tag_class_name} + button {
          border-left: 2px solid #{bg_colour_lowered_opacity};
          border-left-color: oklch(from #{bg_colour} calc(l + 0.1) c h);
        }
        """
      end)

    File.write!(@css_file_path, css_content)
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
