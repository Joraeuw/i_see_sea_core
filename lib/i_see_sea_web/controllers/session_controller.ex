defmodule ISeeSeaWeb.SessionController do
  @moduledoc false
  use ISeeSeaWeb, :controller

  alias ISeeSeaWeb.UserAuth
  alias ISeeSea.Authentication.Auth
  alias ISeeSea.DB.Models.User

  @permission_scope "i_see_sea:sessions"
  plug(AssertPermissions, ["#{@permission_scope}:refresh"] when action == :refresh)
  plug(AssertPermissions, [] when action in [:register, :login, :logout])
  plug(EnsurePermitted)

  def login(conn, %{"_action" => "registered", "user" => user_params}) do
    login(conn, user_params, "Account created successfully!")
  end

  def login(conn, %{"_action" => "password_updated", "user" => user_params}) do
    login(conn, user_params, "Password updated successfully!")
  end

  def login(conn, %{"user" => user_params}) do
    login(conn, user_params, "Welcome back!")
  end

  def login(conn, params, push_message) do
    %{"email" => email, "password" => password} = params

    with {:ok, user} <- User.get_by(%{email: email}),
         true <- User.valid_password?(user, password) do
      conn
      |> put_flash(:info, push_message)
      |> UserAuth.log_in_user(user, params)
    else
      _ ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> put_flash(:email, String.slice(email, 0, 160))
        |> redirect(to: ~p"/login")
    end
  end

  def logout(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end

  def refresh(%{private: %{guardian_default_token: token}} = conn, _params) do
    case Auth.refresh(token) do
      {:ok, new_token} ->
        success(conn, %{token: new_token})

      {:error, _reason} ->
        error(conn, {:error, :unauthorized})
    end
  end
end
