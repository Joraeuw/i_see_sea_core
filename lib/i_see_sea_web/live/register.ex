defmodule ISeeSeaWeb.RegisterLive do
  use ISeeSeaWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, :form_data, %{})
    socket = assign(socket, :errors, %{})

    {:ok, socket}
  end

  @impl true
  def handle_event("submit", %{"register" => params}, socket) do
    {errors, trimmed_params} = validate_params(params)

    socket =
      socket
      |> assign(:errors, errors)
      |> assign(:form_data, trimmed_params)

    if errors == %{} do
      case ISeeSeaWeb.SessionController.register(socket.assigns.conn, trimmed_params) do
        {:ok, %{user: _user, token: _token}} ->
          {:noreply, push_navigate(socket, to: "/")}

        {:error, error} ->
          {:noreply,
           assign(socket, :errors, %{registration_error: "Registration failed: #{error}"})}
      end
    else
      {:noreply, socket}
    end
  end

  defp validate_params(params) do
    trimmed_params = Enum.into(params, %{}, fn {key, value} -> {key, String.trim(value)} end)
    errors = %{}

    errors =
      if trimmed_params["fullName"] == "" do
        Map.put(errors, :full_name, "Fullname is required.")
      else
        errors
      end

    errors =
      if trimmed_params["username"] == "" do
        Map.put(errors, :username, "Username is required.")
      else
        if String.length(trimmed_params["username"]) < 5 do
          Map.put(errors, :username, "Username must be at least 5 characters long.")
        else
          errors
        end
      end

    email_regex = ~r/^[\w.!#$%&’*+\-\/=?\^`{|}~]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*$/i

    errors =
      if trimmed_params["email"] == "" do
        Map.put(errors, :email, "Email is required.")
      else
        if !Regex.match?(email_regex, trimmed_params["email"]) do
          Map.put(errors, :email, "Please enter a valid email address.")
        else
          errors
        end
      end

    password = trimmed_params["password"] || ""
    password_regex = ~r/^(?=.*[a-z])(?=.*[0-9]).{8,30}$/

    errors =
      cond do
        password == "" ->
          Map.put(errors, :password, "Password is required.")

        not Regex.match?(password_regex, password) ->
          Map.put(
            errors,
            :password,
            "Password must be between 8 and 30 characters and contain at least 1 lowercase letter and 1 number."
          )

        true ->
          errors
      end

    {errors, trimmed_params}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="register_container">
      <div class="register">
        <h1 class="register_header">Register</h1>
        <p class="register_p">If you already have an account you can <a href="#">Login</a> now!</p>
        <form phx-submit="submit" class="form">
          <div class="full_name">
            <label class="register_p">Fullname</label>
            <input
              class="input_type"
              type="text"
              name="register[fullName]"
              value={@form_data["fullName"] || ""}
            />
            <span class="register_span">
              <span class="required-ch">*</span>
              <%= if @errors[:full_name] do %>
                <span class="error_div"><%= @errors[:full_name] %></span>
              <% else %>
                Please enter your First and Last name.
              <% end %>
            </span>
          </div>

          <div class="username">
            <label class="register_p">Username</label>
            <input
              class="input_type"
              type="text"
              name="register[username]"
              value={@form_data["username"] || ""}
            />
            <span class="register_span">
              <span class="required-ch">*</span>
              <%= if @errors[:username] do %>
                <span class="error_div"><%= @errors[:username] %></span>
              <% else %>
                Please enter username (5 characters min).
              <% end %>
            </span>
          </div>

          <div class="email">
            <label class="register_p">Email</label>
            <input
              class="input_type"
              type="text"
              name="register[email]"
              value={@form_data["email"] || ""}
            />
            <span class="register_span">
              <span class="required-ch">*</span>
              <%= if @errors[:email] do %>
                <span class="error_div"><%= @errors[:email] %></span>
              <% else %>
                Please enter a valid email address.
              <% end %>
            </span>
          </div>

          <div class="password">
            <label class="register_p">Password</label>
            <input class="input_type" type="password" name="register[password]" />
            <span class="register_span">
              <span class="required-ch">*</span>
              <%= if @errors[:password] do %>
                <span class="error_div"><%= @errors[:password] %></span>
              <% else %>
                The password must contain: Min: 8 characters (1 lowercase letter, 1 number); Max: 30 characters.
              <% end %>
            </span>
          </div>

          <%= if map_size(@errors) > 0 do %>
            <div class="show-popup">Please fill in all required fields.</div>
          <% end %>

          <button class="register_button">Register</button>
        </form>
      </div>
    </div>
    """
  end
end
