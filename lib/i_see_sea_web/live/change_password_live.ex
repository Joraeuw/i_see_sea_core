defmodule ISeeSeaWeb.ChangeLive do
  use ISeeSeaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    # Initialize form data and error handling
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
    if new_password == confirm_password do
      # Passwords match, reset the error and store the form data
      {:noreply,
       assign(socket,
         password_error: false,
         form_data: %{"new_password" => new_password, "confirm_password" => confirm_password}
       )}
    else
      # Passwords do not match, show error message and store the form data
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
          <h1 class="text-[#189ab4] text-xl text-center my-3">Change password</h1>

          <p class="text-[#189ab4]  text-lg text-center">Please enter your new password:</p>
          <input
            id="new_password"
            class="my-3 imt-2 block w-7/12 rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 border-zinc-300 focus:border-zinc-400"
            type="password"
            name="new_password"
            value={@form_data["new_password"]}
          />

          <p class="text-[#189ab4] text-lg text-center">Confirm your new password:</p>
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
            <label for="show_password_checkbox" class="change_p text-lg">Show Passwords</label>
          </div>
          <!-- Conditionally render the error message -->
          <%= if @password_error do %>
            <div class="password-error">
              Passwords do not match!
            </div>
          <% end %>
          <!-- Submit button -->
          <button class="btn mb-5 mt-2" type="submit">Send email</button>
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
end
