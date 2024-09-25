defmodule ISeeSeaWeb.RegisterLive do
  alias ISeeSeaWeb.Params.Session
  alias ISeeSea.DB.Models.User
  use ISeeSeaWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col align-middle rounded-xl shadow-lg shadow-top-bottom mx-auto w-8/12 sm:w-96">
      <.header class="text-center">
        <:subtitle>
          <%= gettext("Already registered?") %>
          <.link navigate={~p"/login"} class="font-semibold text-brand hover:underline text-primary">
            <%= gettext("Log in") %>
          </.link>
          <%= gettext("to your account now.") %>
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/login?_action=registered"}
        method="post"
        class="flex flex-col items-center bg-[url('/images/auth_icons/waveLoginReg.svg')] bg-cover bg-center bg-no-repeat w-full h-full mt-3 space-y-2 shadow-bottom"
      >
        <.error :if={@check_errors}>
          <%= gettext("Oops, something went wrong! Please check the errors below.") %>
        </.error>

        <.input field={@form[:first_name]} type="text" label={gettext("First Name")} required />
        <.input field={@form[:last_name]} type="text" label={gettext("Last Name")} required />
        <.input field={@form[:username]} type="text" label={gettext("Username")} required />
        <.input field={@form[:email]} type="email" label={gettext("Email")} required />
        <.input field={@form[:password]} type="password" label={gettext("Password")} required />

        <:actions>
          <.button phx-disable-with={gettext("Creating account...")} class="w-full">
            <%= gettext("Create an account") %>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    changeset = ISeeSeaWeb.Params.Session.changeset(:register)

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    user_params
    |> ExUtils.Map.atomize_keys(deep: true)
    |> ISeeSea.DB.Logic.SessionOperations.register()
    |> case do
      {:ok, %User{} = user} ->
        changeset = User.changeset(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Session.changeset(:register, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, form: to_form(changeset, as: "user"))
  end
end
