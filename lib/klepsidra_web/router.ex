defmodule KlepsidraWeb.Router do
  use KlepsidraWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout,
      html: {KlepsidraWeb.Layouts, :root},
      swiftui: {KlepsidraWeb.Layouts.SwiftUI, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    # LiveView Native support
    plug LiveViewNative.SessionPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", KlepsidraWeb do
    pipe_through :browser

    # get "/", PageController, :home

    live "/", HelloLive

    live "/tags", TagLive.Index, :index
    live "/tags/new", TagLive.Index, :new
    live "/tags/:id/edit", TagLive.Index, :edit

    live "/tags/:id", TagLive.Show, :show
    live "/tags/:id/show/edit", TagLive.Show, :edit

    live "/timers", TimerLive.Index, :index
    live "/timers/new", TimerLive.Index, :new
    live "/timers/start", TimerLive.Index, :start
    live "/timers/:id/edit", TimerLive.Index, :edit
    live "/timers/:id/stop", TimerLive.Index, :stop

    live "/timers/:id", TimerLive.Show, :show
    live "/timers/:id/show/edit", TimerLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", KlepsidraWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:klepsidra, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: KlepsidraWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
