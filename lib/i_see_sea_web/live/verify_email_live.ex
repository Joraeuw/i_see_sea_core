defmodule ISeeSeaWeb.VerifyEmailLive do
  use ISeeSeaWeb, :live_view

  alias ISeeSeaWeb.Accounts

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.confirm_user(token) do
        {:ok, _} ->
          socket
          |> put_flash(:info, "Your email has been verified!")
          |> redirect(to: ~p"/login")

        :error ->
          socket
          |> put_flash(:error, "Something went wrong when verifying your email.")
          |> redirect(to: ~p"/login")
      end

    {:ok, socket}
  end
end
