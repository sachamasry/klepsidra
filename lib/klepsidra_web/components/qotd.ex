defmodule KlepsidraWeb.AnnotationComponents do
  @moduledoc false

  use Phoenix.Component
  import KlepsidraWeb.CoreComponents

  @doc """
  Renders a quote, presented as a quote of the day.

  ## Examples

      <KlepsidraWeb.AnnotationComponents.quote_of_the_day
        quote={@quote.text}
        author={@quote.author_name}
        navigate={~p"/annotations/#{123}"}
      />
  """
  attr :quote, :string,
    required: true,
    doc: "Quote text"

  attr :author, :string,
    required: true,
    doc: "Author the quote is  attributed to"

  attr(:navigate, :any, required: true)

  @spec quote_of_the_day(assigns :: map()) :: struct()
  def quote_of_the_day(assigns) do
    ~H"""
    <div :if={@quote} class="container flex justify-center my-10">
      <blockquote class="max-w-prose border-y border-double border-violet-500 font-serif subpixel-antialiased italic text-lg px-14 py-6">
        <p class="text-left"><%= @quote %></p>
        <p class="mt-4 text-center">
          <cite>—<%= @author %></cite>
          <.link navigate={@navigate}>
            <.icon
              name="hero-arrow-top-right-on-square"
              class="inline-block align-text-top bg-violet-500 h-3 w-3"
            />
          </.link>
        </p>
      </blockquote>
    </div>
    """
  end
end
