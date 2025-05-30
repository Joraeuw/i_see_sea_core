defmodule ISeeSeaWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use ISeeSeaWeb, :controller
      use ISeeSeaWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt sw.js manifest.json)

  def router do
    quote do
      use Phoenix.Router, helpers: true

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      require ISeeSeaWeb.Lens
      alias ISeeSeaWeb.Focus
      alias ISeeSeaWeb.Lens
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: ISeeSeaWeb.Layouts]

      import Plug.Conn
      use Gettext.Backend, otp_app: :i_see_sea

      import ISeeSeaWeb.Responses
      alias ISeeSeaWeb.Params

      alias ISeeSeaWeb.Plug.AssertPermissions
      alias ISeeSeaWeb.Plug.EnsurePermitted

      unquote(verified_routes())
    end
  end

  def param do
    quote do
      use Goal
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {ISeeSeaWeb.Layouts, :app}

      require ISeeSeaWeb.Lens

      import ISeeSeaWeb.CoreComponents

      alias ISeeSeaWeb.Focus
      alias ISeeSeaWeb.Lens

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import ISeeSeaWeb.CoreComponents
      import ISeeSeaWeb.Trans
      import ISeeSeaWeb.Gettext
      import ISeeSeaWeb.Utils.UserUtils

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      import ISeeSeaWeb.Responses

      alias ISeeSeaWeb.Utils.Validation

      alias ISeeSeaWeb.Router.Helpers, as: Routes
      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: ISeeSeaWeb.Endpoint,
        router: ISeeSeaWeb.Router,
        statics: ISeeSeaWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
