defmodule ISeeSeaWeb.SessionController do
  @moduledoc false
  use ISeeSeaWeb, :controller

  alias ISeeSea.Authentication.Auth
  alias ISeeSea.DB.Models.User

  @permission_scope "i_see_sea:sessions"
  plug(AssertPermissions, ["#{@permission_scope}:refresh"] when action == :refresh)
  plug(AssertPermissions, [] when action in [:register, :login])
  plug(EnsurePermitted)

  def register(conn, params) do
    with {:ok, %{password: password} = validated_params} <- validate(:register, params),
         {:ok, %User{email: email}} <- User.create(validated_params),
         {:ok, %{token: token}} <- Auth.authenticate(%{email: email, password: password}) do
      success(conn, %{token: token})
    else
      error -> error(conn, error)
    end
  end

  def login(conn, params) do
    with {:ok, validated_params} <- validate(:login, params),
         {:ok, %{token: token, user: _user}} <- Auth.authenticate(validated_params) do
      success(conn, %{token: token})
    else
      error ->
        error(conn, error)
    end
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
