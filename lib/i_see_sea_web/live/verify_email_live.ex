defmodule ISeeSeaWeb.VerifyEmailLive do
  use ISeeSeaWeb, :live_view

  alias ISeeSeaWeb.Accounts

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.confirm_user(token) do
        {:ok, _} ->
          socket
          |> put_flash(:info, translate(socket.assigns.locale, "common.email_verified"))
          |> redirect(to: ~p"/login")

        :error ->
          socket
          |> put_flash(
            :error,
            translate(socket.assigns.locale, "something_went_wrong.verify_email")
          )
          |> redirect(to: ~p"/login")
      end

    {:ok, socket}
  end
end
