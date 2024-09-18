defmodule ISeeSeaWeb.ReportCardLiveComponent do
  use ISeeSeaWeb, :live_component

  alias ISeeSea.DB.Models.Picture

  @impl true

  def render(assigns) do
    ~H"""
    <div class="relative w-80 h-96 hover:scale-105">
      <div class={[
        "relative transition-transform duration-[0.5] ease-[ease-in-out] transform-style-preserve-3d",
        if(@is_back, do: "rotate-y-180")
      ]}>
        <!-- Front of the card -->
        <div class={[
          "card card-compact relative shadow-sm left-0 top-0 rotate-y-0 backface-hidden",
          if(not @is_back, do: "shadow-md")
        ]}>
          <figure class="object-cover h-48">
            <img
              class="w-full h-full"
              src={Picture.get_uri!(List.first(@pictures, :not_provided))}
              alt="Report Image"
            />
          </figure>
          <div class="card-body relative shadow-md rounded-md h-48">
            <h2 class="card-title w-full line-clamp-1"><%= @name %></h2>
            <p class="line-clamp-3 w-full"><%= @comment %></p>
            <div class="card-actions justify-end">
              <button phx-click="toggle_flip" phx-target={@myself} class="btn btn-primary">
                Details
              </button>
            </div>
          </div>
        </div>
        <!-- Back of the card -->
        <div
          phx-click="toggle_flip"
          phx-target={@myself}
          class={[
            "card absolute bg-base-100 shadow-sm left-0 top-0 rotate-y-180 backface-hidden",
            if(@is_back, do: "shadow-md")
          ]}
        >
          <div class="card-body shadow-md rounded-md justify-center items-center flex">
            <h2 class="card-title">Back of the Card</h2>
            <p>Additional information about the report.</p>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :is_back, false)}
  end

  @impl true
  def handle_event("toggle_flip", _params, socket) do
    {:noreply, assign(socket, :is_back, !socket.assigns.is_back)}
  end
end
