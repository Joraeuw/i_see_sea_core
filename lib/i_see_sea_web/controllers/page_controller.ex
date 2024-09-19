defmodule ISeeSeaWeb.PageController do
  use ISeeSeaWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def privacy_policy(conn, _params) do
    render(conn, "privacy_policy.html")
  end

  def terms_and_conditions(conn, _params) do
    render(conn, "terms_and_conditions.html")
  end
end
