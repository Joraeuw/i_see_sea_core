defmodule ISeeSeaWeb.LoginLive do
  use ISeeSeaWeb, :live_view
  alias ISeeSea.Authentication.Auth
  alias Phoenix.LiveView

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, :form_data, %{})
    socket = assign(socket, :errors, %{})

    {:ok, socket}
  end

  @impl true
  def handle_event("submit", %{"login" => params}, socket) do

    errors = validate_params(params)

    socket =
      socket
      |> assign(:errors, errors)
      |> assign(:form_data, params)


    if errors == %{} do

      case Auth.authenticate(%{email: params["email"], password: params["password"]}) do
        {:ok, _user_data} ->

          {:noreply, LiveView.push_navigate(socket, to: "/")}

        {:error, :unauthorized, _message} ->

          socket =
            socket
            |> assign(:errors, %{general: "Email or password is incorrect."})

          {:noreply, socket}

        {:error, _other_reason} ->

          socket =
            socket
            |> assign(:errors, %{general: "Something went wrong. Please try again."})

          {:noreply, socket}
      end
    else

      {:noreply, socket}
    end
  end

  defp validate_params(params) do
    errors = %{}

    errors =
      cond do
        params["email"] == "" ->
          Map.put(errors, :email, "Email is required.")

        not Regex.match?(~r/^[\w.%-]+@[\w.-]+\.[a-zA-Z]{2,6}$/, params["email"]) ->
          Map.put(errors, :email, "Invalid email format.")

        true ->
          errors
      end

    password = params["password"] || ""
    errors =
      cond do
        password == "" ->
          Map.put(errors, :password, "Password is required.")

        true ->
          errors
      end

    errors
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="login_container">
      <div class="login">
        <h1 class="login_header">Login</h1>
        <p class="login_p">If you don't have an account you can <a href="#">Register</a> now!</p>

        <form phx-submit="submit" class="form">
          <div class="username">
            <label class="login_p">Email</label>
            <input class="input_type" type="text" name="login[email]" value={@form_data["email"] || ""} />
            <span class="login_span">
              <span class="required-ch">*</span>
              <%= if @errors[:email] do %>
                <span class="error_div"><%= @errors[:email] %></span>
              <% else %>
                Please enter your email.
              <% end %>
            </span>
          </div>

          <div class="password">
            <label class="login_p">Password</label>
            <input class="input_type" type="password" name="login[password]" value={@form_data["password"] || ""} />
            <span class="login_span">
              <span class="required-ch">*</span>
              <%= if @errors[:password] do %>
                <span class="error_div"><%= @errors[:password] %></span>
              <% else %>
                Please enter your password.
              <% end %>
            </span>
            <div class="forgot_password">
              <a class="forgot" href="#"> Forgot password?</a>
            </div>
          </div>

          <!-- Render general error message if present -->
          <%= if @errors[:general] do %>
            <div class="general_error">
              <span class="error_div"><%= @errors[:general] %></span>
            </div>
          <% end %>

          <button class="login_button">Login</button>
        </form>

      </div>
    </div>
    """
  end
end
