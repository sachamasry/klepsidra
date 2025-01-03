defmodule KlepsidraWeb.ErrorHTML do
  @moduledoc false

  use KlepsidraWeb, :html

  # If you want to customize your error pages,
  # uncomment the embed_templates/1 call below
  # and add pages to the error directory:
  #
  #   * lib/klepsidra_web/controllers/error_html/404.html.heex
  #   * lib/klepsidra_web/controllers/error_html/500.html.heex
  #
  # embed_templates "error_html/*"

  # The default is to render a plain text page based on
  # the template name. For example, "404.html" becomes
  # "Not Found".
  @doc false
  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
