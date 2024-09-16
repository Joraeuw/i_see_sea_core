defmodule ISeeSeaWeb.ForgotLive do
  use ISeeSeaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="forgot_container">
      <div class="forgot_div">
        <h1 class="forgot_header">Forgot password</h1>
        <p class="forgot_p">Please enter your E-mail Address:</p>
        <input class="input_type" type="text" />
        <button class="forgot_button">Send email</button>
      </div>
    </div>
    """
  end
end
