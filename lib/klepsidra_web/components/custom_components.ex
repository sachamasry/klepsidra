defmodule KlepsidraWeb.CustomComponents do
  @moduledoc false

  use Phoenix.Component

  import KlepsidraWeb.CoreComponents

  @doc false

  def quote_of_the_day(assigns) do
    ~H"""
    <div :if={@quote} class="container flex justify-center my-10">
      <blockquote class="max-w-prose border-y border-double border-violet-500 font-serif subpixel-antialiased italic text-lg px-14 py-6">
        <p class="text-left"><%= @quote.text %></p>
        <p class="mt-4 text-center">
          <cite>—<%= @quote.author_name %></cite>
          <.link navigate={~p"/annotations/#{@quote.id}"}>
            <Heroicons.arrow_top_right_on_square
              outline
              name="arrow-top-right-on-square"
              class="inline-block align-text-top stroke-violet-500 h-3 w-3"
            />
          </.link>
        </p>
      </blockquote>
    </div>
    """
  end
end
