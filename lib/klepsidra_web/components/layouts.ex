defmodule KlepsidraWeb.Layouts do
  @moduledoc false

  use KlepsidraWeb, :html

  # Changed from embed_templates "layouts/*" for web LiveView only
  embed_templates "layouts/*.html"
end
