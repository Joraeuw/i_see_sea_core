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
    <div class="flex flex-col items-center rounded-xl shadow-lg shadow-top-bottom mx-auto w-[400px] h-10/12 sm:w-96">
      <.header locale={@locale} class="text-center">
        <p class="text-[#189ab4] my-3 text-center">Please enter your E-mail Address:</p>
      </.header>
      <div class="w-full">
        <.simple_form
          locale={@locale}
          for={@form}
          id="forgot_password_form"
          phx-submit="send_email"
          phx-update="ignore"
          class="flex flex-col items-center bg-[url('/images/auth_icons/waveLoginReg.svg')] bg-cover bg-center bg-no-repeat w-full h-full space-y-2 shadow-bottom"
          inner_class="w-12/12"
        >
          <.input
            field={@form[:email]}
            type="email"
            label={translate(@locale, "login.email")}
            required
          />
          <:actions>
            <.button phx-disable-with={translate(@locale, "login.logging_in")} class="btn mb-3">
              <%= translate(@locale, "login.log_in") %>
            </.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    IO.inspect("Handling send_email event", label: "DEBUG")

    case Repo.get_by(User, email: email) do
      nil ->
        {:noreply, socket |> put_flash(:info, "If the email exists, a reset link has been sent.")}

      user ->
        {token, user_token} = UserToken.build_email_token(user, "reset_password")
        Repo.insert!(user_token)

        Emails.password_reset_email(user, token)

        {:noreply, socket |> put_flash(:info, "If the email exists, a reset link has been sent.")}
    end
  end
end
