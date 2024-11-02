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
        """
        .tag-#{tag.name}, .tag-#{tag.name} + button {
          background-color: #{tag.colour || "rgb(148, 163, 184)"};
          color: #{tag.fg_colour || "white"};
        }
        """
      end)

    File.write!(@css_file_path, css_content)
  end
end
