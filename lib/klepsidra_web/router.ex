defmodule KlepsidraWeb.Router do
  use KlepsidraWeb, :router

  @moduledoc false

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash

    plug :put_root_layout,
      html: {KlepsidraWeb.Layouts, :root}

    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", KlepsidraWeb do
    pipe_through :browser

    live "/", StartPageLive
    live "/start_timer", StartPageLive, :start_timer
    live "/stop_timer/:id", StartPageLive, :stop_timer
    live "/new_timer", StartPageLive, :new_timer
    live "/timers/:id", TimerLive.Show, :show
    live "/timer_notes/:id/notes/new", StartPageLive, :new_note
    live "/edit_timer/:id", StartPageLive, :edit_timer

    live "/tags", TagLive.Index, :index
    live "/tags/new", TagLive.Index, :new
    live "/tags/:id/edit", TagLive.Index, :edit

    live "/tags/:id", TagLive.Show, :show
    live "/tags/:id/show/edit", TagLive.Show, :edit

    live "/timers", TimerLive.Index, :index
    live "/timers/new", TimerLive.Index, :new_timer
    live "/timers/start", TimerLive.Index, :start_timer
    live "/timers/:id/edit", TimerLive.Index, :edit_timer
    live "/timers/:id/stop", TimerLive.Index, :stop_timer
    live "/timers/:id/notes/new", TimerLive.Index, :new_note

    live "/timers/:id", TimerLive.Show, :show
    live "/timers/:id/new-note", TimerLive.Show, :new_note
    live "/timers/:id/notes/:note_id/edit", TimerLive.Show, :edit_note
    live "/timers/:id/show/edit", TimerLive.Show, :edit_timer

    live "/activity_types", ActivityTypeLive.Index, :index
    live "/activity_types/new", ActivityTypeLive.Index, :new
    live "/activity_types/:id/edit", ActivityTypeLive.Index, :edit

    live "/activity_types/:id", ActivityTypeLive.Show, :show
    live "/activity_types/:id/show/edit", ActivityTypeLive.Show, :edit

    live "/notes", NoteLive.Index, :index
    live "/notes/new", NoteLive.Index, :new
    live "/notes/:id/edit", NoteLive.Index, :edit

    live "/notes/:id", NoteLive.Show, :show
    live "/notes/:id/show/edit", NoteLive.Show, :edit

    live "/projects", ProjectLive.Index, :index
    live "/projects/new", ProjectLive.Index, :new
    live "/projects/:id/edit", ProjectLive.Index, :edit

    live "/projects/:id", ProjectLive.Show, :show
    live "/projects/:id/show/edit", ProjectLive.Show, :edit

    live "/customers", BusinessPartnerLive.Index, :index
    live "/customers/new", BusinessPartnerLive.Index, :new
    live "/customers/:id/edit", BusinessPartnerLive.Index, :edit

    live "/customers/:id", BusinessPartnerLive.Show, :show
    live "/customers/:id/show/edit", BusinessPartnerLive.Show, :edit
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
