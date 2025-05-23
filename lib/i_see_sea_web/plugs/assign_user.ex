defmodule ISeeSeaWeb.Plug.AssignUser do
  @moduledoc false

  @remember_me_cookie "_auth_web_user_remember_me"

  alias ISeeSea.DB.Models.UserToken

  import Plug.Conn

  def fetch_current_user(conn, _opts) do
    {token, conn} = fetch_token(conn)
    user = token && UserToken.verify_session_token_query(token)
    assign(conn, :current_user, user)
  end

  defp fetch_token(conn) do
    case get_session(conn, :user_token, :not_found) do
      :not_found ->
        conn = fetch_cookies(conn, signed: [@remember_me_cookie])

        if token = conn.cookies[@remember_me_cookie] do
          {token, put_token_in_session(conn, token)}
        else
          {nil, conn}
        end

      token ->
        merge_assigns(token, conn)
    end
  end

  defp put_token_in_session(conn, token) do
    conn
    |> put_session(:user_token, token)
    |> put_session(:live_socket_id, "i_see_sea:sessions:#{Base.url_encode64(token)}")
  end
end
