defmodule ISeeSeaWeb.LoginLive do
  use ISeeSeaWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center rounded-xl shadow-lg shadow-top-bottom  mx-auto w-8/12 sm:w-96">
      <.header locale={@locale} class="text-center">
        <%= translate(@locale, "login.log_in_to_account") %>
        <:subtitle>
          <%= translate(@locale, "login.no_account") %>
          <.link navigate={~p"/register"} class="font-semibold text-brand hover:underline">
            <%= translate(@locale, "login.sign_up") %>
          </.link>
          <%= translate(@locale, "login.account_now") %>
        </:subtitle>
      </.header>
      <div class="w-full">
        <.simple_form
          locale={@locale}
          for={@form}
          id="login_form"
          action={~p"/login"}
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
          <.input
            field={@form[:password]}
            type="password"
            label={translate(@locale, "login.password")}
            required
          />

          <:actions>
            <.input
              field={@form[:remember_me]}
              type="checkbox"
              label={translate(@locale, "login.keep_me_logged")}
            />
            <.link href={~p"/forgot_password"} class="text-sm font-semibold">
              <%= translate(@locale, "login.forgot_password") %>
            </.link>
          </:actions>
          <:actions>
            <.button phx-disable-with={translate(@locale, "login.logging_in")} class="btn mb-3">
              <%= translate(@locale, "login.log_in") %><span aria-hidden="true">→</span>
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
