defmodule ISeeSeaWeb.NavMenuLive do
  use ISeeSeaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <nav class="bg-gray-800 p-4 flex justify-between items-center">
      <div class="text-white text-2xl font-bold">
        <%=t!(@locale,"Sea Report")%>
      </div>
      <ul class="flex space-x-4">
        <%!-- <li><a href="<%= Routes.home_path(@socket, :index) %>" class="text-white px-3 py-2 rounded-md text-sm font-medium hover:bg-gray-700">Home</a></li> --%>
        <%!-- <li><a href="" class="text-white px-3 py-2 rounded-md text-sm font-medium hover:bg-gray-700">About</a></li> --%>
      </ul>
    </nav>
    """
  end
end
