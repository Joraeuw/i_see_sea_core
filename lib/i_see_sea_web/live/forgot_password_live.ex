defmodule ISeeSeaWeb.ForgotLive do
  use ISeeSeaWeb, :live_view
  alias ISeeSeaWeb.HomeComponents
  alias ISeeSea.DB.Models.BaseReport

  @impl true
  def mount(_params, _session, socket) do
   {:ok,socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="flex flex-col items-center justify-start w-full h-screen p-5 box-border">
    <div class="flex flex-col shadow-lg justify-between items-center h-auto max-h-[400px] w-full max-w-[600px] rounded-lg bg-no-repeat bg-cover p-5 box-border" style="background-image: url('/images/auth_icons/waveLoginReg.svg'); background-size: cover; background-position: center;">

        <h1 class="text-[#189ab4] my-3 text-xl font-medium mb-5 text-center">Forgot password</h1>
        <p class="text-[#189ab4] my-3 text-center">Please enter your E-mail Address:</p>
        <input class=" mt-2 block my-3 w-7/12 rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 border-zinc-300 focus:border-zinc-400" type="text" />
        <button class="btn my-4">Send email</button>
      </div>
    </div>
    """
  end
end
