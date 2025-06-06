defmodule ISeeSeaWeb.RegisterLive do
  alias ISeeSeaWeb.Params.Session
  alias ISeeSea.DB.Models.User
  use ISeeSeaWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col align-middle rounded-xl shadow-lg shadow-top-bottom mx-auto w-8/12 sm:w-96">
      <.header locale={@locale} class="text-center">
        <:subtitle>
          <%= translate(@locale, "register.already_registered") %>
          <.link navigate={~p"/login"} class="font-semibold text-brand hover:underline text-primary">
            <%= translate(@locale, "register.log_in") %>
          </.link>
          <%= translate(@locale, "register.account_now") %>
        </:subtitle>
      </.header>

      <.simple_form
        locale={@locale}
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
          <%= translate(@locale, "register.sth_went_wrong_check_errors") %>
        </.error>

        <.input
          field={@form[:first_name]}
          type="text"
          label={translate(@locale, "register.first_name")}
          required
        />
        <.input
          field={@form[:last_name]}
          type="text"
          label={translate(@locale, "register.last_name")}
          required
        />
        <.input
          field={@form[:username]}
          type="text"
          label={translate(@locale, "register.username")}
          required
        />
        <.input
          field={@form[:email]}
          type="email"
          label={translate(@locale, "register.email")}
          required
        />
        <.input
          field={@form[:password]}
          type="password"
          label={translate(@locale, "register.password")}
          required
        />

        <:actions>
          <.button phx-disable-with={translate(@locale, "register.creating_account")} class="btn mb-1">
            <%= translate(@locale, "register.create_account") %>
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
