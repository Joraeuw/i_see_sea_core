defmodule ISeeSeaWeb.LoginLive do
  use ISeeSeaWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col justify-evenly items-center rounded-xl shadow-lg shadow-top-bottom  mx-auto w-4/12">
      <.header class="text-center">
        Log in to account
        <:subtitle>
          Don't have an account?
          <.link navigate={~p"/register"} class="font-semibold text-brand hover:underline">
            Sign up
          </.link>
          for an account now.
        </:subtitle>
      </.header>
      <div class="w-full">
      <.simple_form
      for={@form}
      id="login_form"
      action={~p"/login"}
      phx-update="ignore"
      class="flex flex-col items-center bg-[url('/images/Assetss/waveLoginReg.svg')] bg-cover bg-center bg-no-repeat w-full h-full space-y-2 shadow-bottom">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
          <.link href={~p"/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Logging in..." class="w-full mb-[5px]">
            Log in <span aria-hidden="true">→</span>
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
