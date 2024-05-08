defmodule ISeeSeaWeb.Router do
  use ISeeSeaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ISeeSeaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug OpenApiSpex.Plug.PutApiSpec, module: ISeeSeaWeb.ApiSpec
  end

  pipeline :authenticated do
    plug ISeeSeaWeb.Plug.EnsureAuthenticated
  end

  scope "/", ISeeSeaWeb do
    pipe_through :browser

    get "/", PageController, :home

    post "/login", SessionController, :login
    post "/register", SessionController, :register

    ## Reports
    scope "/reports" do
      get "/:report_type", ReportController, :index
    end
  end

  scope "/api" do
    pipe_through :api

    get "/spec/openapi", OpenApiSpex.Plug.RenderSpec, []
    get "/doc", Redoc.Plug.RedocUI, spec_url: "/api/spec/openapi"
  end

  scope "/api", ISeeSeaWeb do
    pipe_through :authenticated

    get "/refresh", SessionController, :refresh

    ## Reports
    scope "/reports" do
      post "/create/:report_type", ReportController, :create_report
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:i_see_sea, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ISeeSeaWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
