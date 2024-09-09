defmodule ISeeSeaWeb.LoginLive do
  use ISeeSeaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="login_container">
      <div class="login">
        <h1 class="login_header">Login</h1>
        <p class="login_p">If you don't have an account you can <a href="#">Register</a> now!</p>
        <div class="username">
        <label class="login_p">Username</label>
        <input class="input_type" type="text" name="fullName"/>
        <span class="login_span">
        <span class="required-ch">*</span>
        Please enter your username.
        </span></div>
        <div class=password>
        <label class="login_p">Password</label>
        <input class="input_type" type="text" name="fullName"/>
        <span class="login_span">
        <span class="required-ch">*</span>
        Please enter your password.
        </span>
        <a class="forgot" href="#"> Forgot password?</a>
        </div>
        <button class="login_button">Login</button>

      <div>
    </div>
    """
  end
end
