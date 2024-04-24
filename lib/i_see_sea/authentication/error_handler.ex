defmodule ISeeSea.Authentication.ErrorHandler do
  @moduledoc false
  @behaviour Guardian.Plug.ErrorHandler

  use Phoenix.Controller

  alias ISeeSeaWeb.Responses

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {_type, _reason}, _opts) do
    Responses.error(conn, {:error, :unauthorized})
  end
end
