defmodule KlepsidraWeb.ButtonComponents do
  @moduledoc false

  use Phoenix.Component

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr(:type, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(disabled form name value))

  slot(:inner_block, required: true)

  def outline_button(assigns) do
    ~H"""
    <button
      type="button"
      class={[
        "phx-submit-loading:opacity-75 rounded-lg py-2 px-3",
        "text-sm font-semibold leading-6 text-white active:text-white/80",
        "flex-none flex-grow-0 h-fit self-end",
        "[&&]:bg-violet-50/0 border border-peach-fuzz-500 [&&]:text-peach-fuzz-500",
        "hover:border-peach-fuzz-700 [&&]:hover:text-peach-fuzz-700",
        "[&&]:py-1 rounded-md",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end
end
