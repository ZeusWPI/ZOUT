defmodule ZoutWeb.Router do
  use ZoutWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html", "json"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_layout, html: {ZoutWeb.LayoutView, :app}
    plug :put_root_layout, {ZoutWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :auth do
    plug ZoutWeb.Auth.Pipeline
  end

  pipeline :api do
    plug :accepts, ["html", "json"]
  end

  pipeline :admin do
    plug :admin_only
  end

  scope "/", ZoutWeb do
    pipe_through [:browser, :auth]

    get "/", PageController, :index
    get "/crash", PageController, :crash

    resources "/projects", ProjectController
    resources "/pings", PingController, only: [:show]

    get "/import", ImportController, :index
    post "/import", ImportController, :import

    scope "/auth" do
      get "/:provider/callback", AuthController, :callback
      get "/:provider", AuthController, :request
      post "/logout", AuthController, :logout
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", ZoutWeb do
  #   pipe_through :api
  # end

  defp admin_only(conn, _opts) do
    alias Zout.Data
    user = Guardian.Plug.current_resource(conn)
    # Ugly hack...
    Bodyguard.permit!(Data.Policy, :is_admin, user)
    conn
  end

  scope "/" do
    pipe_through [:browser, :auth, :admin]

    live_dashboard "/dashboard", metrics: ZoutWeb.Telemetry
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
