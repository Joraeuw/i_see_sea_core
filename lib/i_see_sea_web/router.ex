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

  pipeline :image_uploading do
    plug Plug.Parsers,
      parsers: [:json, :multipart],
      pass: ["*/*"],
      json_decoder: Phoenix.json_library()
  end

  pipeline :authenticated do
    plug ISeeSeaWeb.Plug.EnsureAuthenticated
  end

  scope "/", ISeeSeaWeb do
    pipe_through :browser

    live "/", HomeLive, :index
    live "terms", TermLive, :index
    # live "/", HomePageLive
  end

  scope "/api" do
    pipe_through :api

    get "/spec/openapi", OpenApiSpex.Plug.RenderSpec, []
    get "/doc", Redoc.Plug.RedocUI, spec_url: "/api/spec/openapi"
  end

  scope "/api", ISeeSeaWeb do
    pipe_through :api

    post "/login", SessionController, :login
    post "/register", SessionController, :register
    get "/verify-email/:token", UserController, :verify_email

    scope "/users" do
      post "/forgot-password", UserController, :forgot_password
      post "/reset-password/:token", UserController, :reset_password
    end

    ## Constants
    scope "/constants" do
      get("/picture_type", ConstantsController, :picture_type)
      get("/jellyfish_quantity", ConstantsController, :jellyfish_quantity)
      get("/jellyfish_species", ConstantsController, :jellyfish_species)
      get("/pollution_type", ConstantsController, :pollution_type)
      get("/report_type", ConstantsController, :report_type)
      get("/fog_type", ConstantsController, :fog_type)
      get("/sea_swell_type", ConstantsController, :sea_swell_type)
      get("/wind_type", ConstantsController, :wind_type)
      get("/storm_type", ConstantsController, :storm_type)
    end

    ## Reports
    scope "/reports" do
      get "/:report_type", ReportController, :index
    end

    scope "/pictures" do
      get "/:picture_id", PictureController, :show
    end
  end

  scope "/api", ISeeSeaWeb do
    pipe_through :authenticated

    get "/refresh", SessionController, :refresh

    ## Users
    scope "/users" do
      get "/me", UserController, :user_info
      get "/reports/:report_type", UserController, :list_reports
    end

    ## Reports
    scope "/reports" do
      delete "/delete/:report_id", ReportController, :delete_report

      pipe_through :image_uploading

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
