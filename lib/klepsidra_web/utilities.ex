defmodule KlepsidraWeb.Utilities do
  @moduledoc false

  @doc false
  def toast_class_fn(assigns) do
    [
      # base classes
      "group/toast z-100 pointer-events-auto relative w-full items-center justify-between origin-center overflow-hidden rounded-lg p-4 shadow-lg border border-peach-fuzz-500 col-start-1 col-end-1 row-start-1 row-end-2",
      # start hidden if javascript is enabled
      "[@media(scripting:enabled)]:opacity-0 [@media(scripting:enabled){[data-phx-main]_&}]:opacity-100",
      # used to hide the disconnected flashes
      if(assigns[:rest][:hidden] == true, do: "hidden", else: "flex"),
      # override styles per severity
      assigns[:kind] == :info && "bg-peach-fuzz-lightness-25/100 text-black",
      assigns[:kind] == :error && "!text-rose-700 !bg-rose-100 border-rose-200"
    ]
  end
end
