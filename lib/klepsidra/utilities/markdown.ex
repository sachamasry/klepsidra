defmodule Klepsidra.Markdown do
  @moduledoc """
  Handle Markdown strings, parsing and converting them to desired
  target formats.
  """

  @full_markdown_to_html_conversion_extensions [
    strikethrough: true,
    tagfilter: true,
    table: true,
    autolink: true,
    tasklist: true,
    superscript: true,
    header_ids: "user-content-",
    footnotes: true,
    description_lists: true,
    front_matter_delimiter: "-----",
    multiline_block_quotes: true,
    alerts: true,
    math_dollars: true,
    math_code: true,
    shortcodes: true,
    subscript: true,
    spoiler: true,
    greentext: true
  ]

  @full_markdown_to_html_parse_options [
    smart: true,
    relaxed_tasklist_matching: true,
    relaxed_autolinks: true
  ]

  @full_markdown_to_html_render_options [
    github_pre_lang: true,
    full_info_string: true,
    unsafe_: true,
    figure_with_caption: true
  ]

  @doc """
  Convert a Markdown string, paring it and converting it to HTML.

  The MDEx library is used for parsing and conversion, `to_html/2`
  passes it default options, extensions expected to be used.
  """
  @spec to_html(markdown :: binary(), opts :: list()) ::
          {:ok, bitstring()} | {:error, map()}
  def to_html(markdown \\ "", opts \\ [])

  def to_html(markdown, _opts) when is_bitstring(markdown) do
    MDEx.to_html(markdown,
      extension: @full_markdown_to_html_conversion_extensions,
      parse: @full_markdown_to_html_parse_options,
      render: @full_markdown_to_html_render_options,
      features: [sanitize: true, syntax_highlight_theme: "catpuccin_macchiato"]
    )
  end

  def to_html!(markdown \\ "", opts \\ [])

  def to_html!(markdown, _opts) when is_bitstring(markdown) do
    MDEx.to_html!(markdown,
      extension: @full_markdown_to_html_conversion_extensions,
      parse: @full_markdown_to_html_parse_options,
      render: @full_markdown_to_html_render_options,
      features: [sanitize: true, syntax_highlight_theme: "catpuccin_macchiato"]
    )
  end
end
