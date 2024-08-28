defmodule ISeeSeaWeb.HomeLive do
  use ISeeSeaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="bg-gray-100">
      <main class="p-6 h-max">
      <%= live_render(@socket, ISeeSeaWeb.MapLive, id: "map-live") %>
      </main>
    </div>
    """
  end
end
