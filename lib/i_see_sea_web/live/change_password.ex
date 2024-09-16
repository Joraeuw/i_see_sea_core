defmodule ISeeSeaWeb.ChangeLive do
  use ISeeSeaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    # Initialize form data and error handling
    {:ok, assign(socket, form_data: %{"new_password" => "", "confirm_password" => ""}, password_error: false)}
  end

  @impl true
  def handle_event("check_passwords", %{"new_password" => new_password, "confirm_password" => confirm_password}, socket) do
    if new_password == confirm_password do
      # Passwords match, reset the error and store the form data
      {:noreply, assign(socket, password_error: false, form_data: %{"new_password" => new_password, "confirm_password" => confirm_password})}
    else
      # Passwords do not match, show error message and store the form data
      {:noreply, assign(socket, password_error: true, form_data: %{"new_password" => new_password, "confirm_password" => confirm_password})}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="change_container">
      <div class="change_div">
        <form phx-submit="check_passwords" class="form">
          <h1 class="change_header">Change password</h1>

          <p class="change_p">Please enter your new password:</p>
          <input id="new_password" class="input_type_change" type="password" name="new_password" value={@form_data["new_password"]} />

          <p class="change_p">Confirm your new password:</p>
          <input id="confirm_password" class="input_type_change" type="password" name="confirm_password" value={@form_data["confirm_password"]} />

          <!-- Checkbox to toggle password visibility -->
          <div class="show-password-div">
            <input id="show_password_checkbox" type="checkbox" onclick="togglePasswordVisibility()" />
            <label for="show_password_checkbox" class="change_p">Show Passwords</label>
          </div>

          <!-- Conditionally render the error message -->
          <%= if @password_error do %>
            <div class="password-error">
              Passwords do not match!
            </div>
          <% end %>

          <!-- Submit button -->
          <button class="change_button" type="submit">Send email</button>
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
