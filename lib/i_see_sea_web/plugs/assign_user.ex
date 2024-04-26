defmodule ISeeSeaWeb.Plug.AssignUser do
  @moduledoc false

  alias ISeeSeaWeb.Responses
  alias ISeeSea.DB.Models.User

  def init(opts), do: opts

  def call(conn, _opts) do
    case Guardian.Plug.current_resource(conn) do
      %User{} = user ->
        Plug.Conn.merge_assigns(conn, user: user)

      _error ->
        conn
        |> Responses.error({:error, :unauthorized})
        |> Plug.Conn.halt()
    end
  end
end
