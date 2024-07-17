defmodule ISeeSeaWeb.Plug.AssertPermissions do
  @moduledoc """
  Controls permission access to routes.
  """

  alias ISeeSeaWeb.Responses
  alias ISeeSea.Authentication.Tokenizer
  alias ISeeSea.DB.Models.User

  def init(permissions), do: permissions

  def call(conn, permissions) do
    has_permission =
      case permissions do
        [] ->
          true

        _ ->
          conn
          |> Tokenizer.Plug.current_resource()
          |> has_permissions?(permissions)
      end

    maybe_halt(conn, has_permission)
  end

  defp maybe_halt(conn, true) do
    Plug.Conn.assign(conn, :forbidden, false)
  end

  defp maybe_halt(conn, false) do
    conn
    |> Plug.Conn.assign(:forbidden, true)
    |> Responses.error({:error, :forbidden})
    |> Plug.Conn.halt()
  end

  defp has_permissions?(%User{}, []), do: true

  defp has_permissions?(%User{role: %{permissions: user_permissions}}, permissions) do
    Enum.any?(user_permissions, fn %{name: user_permission} ->
      Enum.member?(permissions, user_permission)
    end)
  end
end
