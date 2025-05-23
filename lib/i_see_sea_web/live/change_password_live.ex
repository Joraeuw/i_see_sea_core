defmodule ISeeSeaWeb.ChangeLive do
  alias ISeeSeaWeb.Accounts
  use ISeeSeaWeb, :live_view

  @impl true
  def mount(params, _session, socket) do
    socket = assign_user_by_token(socket, params)

    {:ok,
     assign(socket,
       form_data: %{"new_password" => "", "confirm_password" => ""},
       password_error: false
     )}
  end

  @impl true
  def handle_event(
        "check_passwords",
        %{"new_password" => new_password, "confirm_password" => confirm_password},
        socket
      ) do
    if String.equivalent?(new_password, confirm_password) do
      Accounts.reset_user_password(socket.assigns.user, new_password)

      {:noreply,
       socket
       |> put_flash(:info, translate(socket.assigns.locale, "common.changed_password"))
       |> redirect(to: ~p"/login")}
    else
      {:noreply,
       assign(socket,
         password_error: true,
         form_data: %{"new_password" => new_password, "confirm_password" => confirm_password}
       )}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-start w-full h-screen p-5">
      <div
        class="flex flex-col justify-between items-center  rounded-lg bg-no-repeat bg-cover w-11/12 max-w-[600px] h-auto
    max-h-[800px]"
        style="background-image: url('/images/auth_icons/waveLoginReg.svg'); background-size: cover; background-position: center;"
      >
        <form
          phx-submit="check_passwords"
          class="flex flex-col justify-between items-center w-full h-full rounded-lg bg-no-repeat bg-cover"
        >
          <h1 class="text-[#189ab4] text-xl text-center my-3">
            <%= translate(@locale, "change_password.title") %>
          </h1>

          <p class="text-[#189ab4]  text-lg text-center">
            <%= translate(@locale, "change_password.prompt") %>
          </p>
          <input
            id="new_password"
            class="my-3 imt-2 block w-7/12 rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 border-zinc-300 focus:border-zinc-400"
            type="password"
            name="new_password"
            value={@form_data["new_password"]}
          />

          <p class="text-[#189ab4] text-lg text-center">
            <%= translate(@locale, "change_password.confirm") %>
          </p>
          <input
            id="confirm_password"
            class="my-3  mt-2 block w-7/12 rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 border-zinc-300 focus:border-zinc-400"
            type="password"
            name="confirm_password"
            value={@form_data["confirm_password"]}
          />
          <!-- Checkbox to toggle password visibility -->
          <div class="show-password-div my-3">
            <input id="show_password_checkbox" type="checkbox" onclick="togglePasswordVisibility()" />
            <label for="show_password_checkbox" class="change_p text-lg">
              <%= translate(@locale, "change_password.show_password") %>
            </label>
          </div>
          <!-- Conditionally render the error message -->
          <%= if @password_error do %>
            <div class="password-error">
              <%= translate(@locale, "change_password.passwords_not_matching") %>
            </div>
          <% end %>
          <!-- Submit button -->
          <button class="btn mb-5 mt-2" type="submit">
            <%= translate(@locale, "change_password.submit") %>
          </button>
        </form>
      </div>
    </div>

    <script>
      function togglePasswordVisibility() {
        var newPasswordInput = document.getElementById("new_password");
        var confirmPasswordInput = document.getElementById("confirm_password");
        var checkbox = document.getElementById("show_password_checkbox");

        if (checkbox.checked) {
          newPasswordInput.type = "text";
          confirmPasswordInput.type = "text";
        } else {
          newPasswordInput.type = "password";
          confirmPasswordInput.type = "password";
        }
      }
    </script>
    """
  end

  defp assign_user_by_token(socket, %{"token" => token}) do
    if user = Accounts.get_user_by_reset_password_token(token) do
      assign(socket, user: user, token: token)
    else
      socket
      |> put_flash(
        :error,
        translate(socket.assigns.locale, "common.invalid_link")
      )
      |> redirect(to: ~p"/")
    end
  end
end
