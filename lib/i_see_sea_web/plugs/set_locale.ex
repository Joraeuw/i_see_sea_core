defmodule ISeeSeaWeb.Plug.SetLocale do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _opts) do
    locale =
      conn
      |> fetch_cookies()
      |> Map.get(:cookies)
      |> Map.get("locale", "en")

    conn
    |> put_session(:locale, locale)
    |> assign(:locale, locale)
  end

  def on_mount(:mount_locale, _params, session, socket) do
    socket =
      Phoenix.Component.assign_new(socket, :locale, fn ->
        Map.get(session, "locale")
      end)

    {:cont, socket}
  end
end
