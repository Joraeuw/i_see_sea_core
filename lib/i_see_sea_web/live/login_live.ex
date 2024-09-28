defmodule ISeeSeaWeb.LoginLive do
  use ISeeSeaWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center rounded-xl shadow-lg shadow-top-bottom  mx-auto w-8/12 sm:w-96">
      <.header locale={@locale} class="text-center">
      <%=t!(@locale,"login.log_in_to_account")%>
        <:subtitle>
          <%=t!(@locale,"login.no_account")%>
          <.link navigate={~p"/register"} locale={@locale} class="font-semibold text-brand hover:underline">
            <%=t!(@locale,"login.sign_up")%>
          </.link>
          <%=t!(@locale,"login.account_now")%>
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
        >
          <.input field={@form[:email]} type="email" label={t!(@locale,"login.email")} required />
          <.input field={@form[:password]} type="password" label={t!(@locale,"login.password")} required />

          <:actions>
            <.input field={@form[:remember_me]} type="checkbox" label={t!(@locale,"login.keep_me_logged")} />
            <.link href={~p"/reset_password"} class="text-sm font-semibold">
              <%=t!(@locale,"login.forgot_password")%>
            </.link>
          </:actions>
          <:actions>
            <.button phx-disable-with={t!(@locale,"login.logging_in")} class="w-full">
              <%=t!(@locale,"login.log_in")%><span aria-hidden="true">→</span>
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
    {:ok, assign(socket, locale: "bg", form: form), temporary_assigns: [form: form]}
  end
end
