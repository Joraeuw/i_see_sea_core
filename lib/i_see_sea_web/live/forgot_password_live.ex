defmodule ISeeSeaWeb.ForgotLive do
  use ISeeSeaWeb, :live_view
  alias ISeeSea.Repo
  alias ISeeSea.DB.Models.User
  alias ISeeSea.DB.Models.UserToken
  alias ISeeSea.Emails

  @impl true
  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center rounded-t-lg">
      <.header locale={@locale} class="text-center">
        <p class="text-[#189ab4] text-center my-1 mx-3">
          <%= translate(@locale, "forgot_password.title") %>
        </p>
      </.header>
      <div class="w-full rounded-b-lg overflow-hidden">
        <.simple_form
          locale={@locale}
          for={@form}
          id="forgot_password_form"
          phx-submit="send_email"
          phx-update="ignore"
          class="flex flex-col items-center bg-[url('/images/auth_icons/waveLoginReg.svg')] bg-cover bg-center rounded-lg overflow-hidden bg-no-repeat w-full h-full space-y-2 shadow-bottom"
          inner_class="w-12/12"
        >
          <.input field={@form[:email]} type="email" required />
          <:actions>
            <.button phx-disable-with={translate(@locale, "login.logging_in")} class="btn mb-3">
              <%= translate(@locale, "forgot_password.send_email") %>
            </.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    case Repo.get_by(User, email: email) do
      nil ->
        nil

      user ->
        {token, user_token} = UserToken.build_email_token(user, "reset_password")
        Repo.insert!(user_token)

        Emails.password_reset_email(user, token)
    end

    {:noreply,
     socket
     |> put_flash(
       :info,
       translate(socket.assigns.locale, "common.sent_reset_link")
     )}
  end
end
