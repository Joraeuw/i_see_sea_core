defmodule ISeeSeaWeb.SessionController do
  @moduledoc false
  use ISeeSeaWeb, :controller

  alias ISeeSea.Repo
  alias ISeeSea.Events.UserEmailVerification
  alias ISeeSea.Emails
  alias ISeeSea.Authentication.Auth
  alias ISeeSea.DB.Models.User

  @permission_scope "i_see_sea:sessions"
  plug(AssertPermissions, ["#{@permission_scope}:refresh"] when action == :refresh)
  plug(AssertPermissions, [] when action in [:register, :login])
  plug(EnsurePermitted)

  def register(conn, params) do
    with {:ok, validated_params} <- validate(:register, params),
         {:ok, {user, token}} <- do_register(validated_params) do
      success(conn, %{user: user, token: token})
    else
      error -> error(conn, error)
    end
  end

  def login(conn, params) do
    with {:ok, validated_params} <- validate(:login, params),
         {:ok, user_data} <- Auth.authenticate(validated_params) do
      success(conn, user_data)
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

  defp do_register(%{password: password} = validated_params) do
    Repo.transaction(fn ->
      with {:ok, %User{id: user_id, email: email} = user} <- User.create(validated_params),
           uuid <- UUID.uuid4(:hex),
           UserEmailVerification.start_tracker(user_id, uuid),
           {:ok, _} <- Emails.account_confirmation_email(user, uuid),
           {:ok, %{token: token}} <- Auth.authenticate(%{email: email, password: password}) do
        {user, token}
      else
        {:error, error} -> Repo.rollback(error)
      end
    end)
  end
end
