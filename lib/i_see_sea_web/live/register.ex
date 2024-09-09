defmodule ISeeSeaWeb.RegisterLive do
  use ISeeSeaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="register_container">
      <div class="register">
        <h1 class="register_header">Register</h1>
        <p class="register_p">If you allreay have an account you can <a href="#">Login</a> now!</p>
        <div class="full_name">
          <label class="register_p">Fullname</label>
          <input class="input_type" type="text" name="fullName"/>
          <span class="register_span">
          <span class="required-ch">*</span>
          Please enter your First and Last name.
          </span>
        </div>
        <div class="username">
        <label class="register_p">Username</label>
        <input class="input_type" type="text" name="fullName"/>
        <span class="register_span">
        <span class="required-ch">*</span>
        Please enter username (20 characters max).
        </span></div>
        <div class="email">
        <label class="register_p">Email</label>
        <input class="input_type" type="text" name="fullName"/>
        <span class="register_span">
        <span class="required-ch">*</span>
        Please enter valid email address.
        </span></div>
        <div class=password>
        <label class="register_p">Password</label>
        <input class="input_type" type="text" name="fullName"/>
        <span class="register_span">
        <span class="required-ch">*</span>
        The password must contain: Min: 8 characters (1 uppercase letter, 1 lowercase letter, 1 special character, 1 number); Max: 30 characters.
        </span></div>
        <button class="register_button">Register</button>

      <div>
    </div>
    """
  end
end
