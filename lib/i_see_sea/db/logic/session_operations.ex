defmodule ISeeSea.DB.Logic.SessionOperations do
  alias ISeeSea.Emails
  alias ISeeSea.Repo
  alias ISeeSea.Events.UserEmailVerification
  alias ISeeSea.DB.Models.User

  def register(validated_params) do
    Repo.transaction(fn ->
      with {:ok, %User{id: user_id} = user} <- User.create(validated_params),
           uuid <- UUID.uuid4(:hex),
           UserEmailVerification.start_tracker(user_id, uuid),
           {:ok, _} <- Emails.account_confirmation_email(user, uuid) do
        user
      else
        {:error, error} -> Repo.rollback(error)
      end
    end)
  end

  def put_token_in_session(conn, token) do
    conn
    |> Plug.Conn.put_session(:user_token, token)
    |> Plug.Conn.put_session(:live_socket_id, "i_see_sea:sessions:#{Base.url_encode64(token)}")
  end

  def maybe_write_remember_me_cookie(conn, token, %{"remember_me" => "true"}) do
    Plug.Conn.put_resp_cookie(conn, @remember_me_cookie, token, @remember_me_options)
  end

  def maybe_write_remember_me_cookie(conn, _token, _params) do
    conn
  end
end
