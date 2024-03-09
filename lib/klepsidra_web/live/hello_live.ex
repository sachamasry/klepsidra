defmodule KlepsidraWeb.HelloLive do
  use Phoenix.LiveView
  use KlepsidraWeb, :live_view

  @impl true
  def render(%{format: :swiftui} = assigns) do
    # This UI renders on the iPhone / iPad app
    ~SWIFTUI"""
    <VStack>
  <Text>
      Hello native!
    </Text>
  </VStack>
    """
    end

  @impl true
  def render(%{} = assigns) do
    # This UI renders on the web
    ~H"""
    <div class="flex w-full h-screen items-center">
    <span class="w-full text-center">
    Hello web!
    </span>
    </div>
    """
  end
end
