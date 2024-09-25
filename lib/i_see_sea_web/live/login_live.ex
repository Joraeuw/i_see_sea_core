defmodule ISeeSeaWeb.LoginLive do
  use ISeeSeaWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center rounded-xl shadow-lg shadow-top-bottom  mx-auto w-8/12 sm:w-96">
      <.header class="text-center">
        <%= gettext("Log in to account") %>
        <:subtitle>
          <%= gettext("Don't have an account?") %>
          <.link navigate={~p"/register"} class="font-semibold text-brand hover:underline">
            <%= gettext("Sign up") %>
          </.link>
          <%= gettext("for an account now.") %>
        </:subtitle>
      </.header>
      <div class="w-full">
        <.simple_form
          for={@form}
          id="login_form"
          action={~p"/login"}
          phx-update="ignore"
          class="flex flex-col items-center bg-[url('/images/auth_icons/waveLoginReg.svg')] bg-cover bg-center bg-no-repeat w-full h-full space-y-2 shadow-bottom"
        >
          <.input field={@form[:email]} type="email" label={gettext("Email")} required />
          <.input field={@form[:password]} type="password" label={gettext("Password")} required />

          <:actions>
            <.input field={@form[:remember_me]} type="checkbox" label={gettext("Keep me logged in")} />
            <.link href={~p"/reset_password"} class="text-sm font-semibold">
              <%= gettext("Forgot your password?") %>
            </.link>
          </:actions>
          <:actions>
            <.button phx-disable-with={gettext("Logging in...")} class="w-full">
              <%= gettext("Log in ") %><span aria-hidden="true">→</span>
            </.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
