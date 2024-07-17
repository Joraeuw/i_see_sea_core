defmodule ISeeSeaWeb.Plug.EnsurePermitted do
  @moduledoc """
  Ensures that AssertPermissions has been defined for every route.
  """

  alias ISeeSeaWeb.Responses

  def init(opts), do: opts

  def call(%{assigns: assigns} = conn, _opts) do
    Map.get(assigns, :forbidden, true)
    |> if do
      conn
      |> Responses.error({:error, :forbidden})
      |> Plug.Conn.halt()
    else
      conn
    end
  end
end
