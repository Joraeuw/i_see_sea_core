defmodule ISeeSeaWeb.CommonComponents do
  alias ISeeSeaWeb.HomeComponents
  use Phoenix.Component

  attr :current_page, :integer, required: true
  attr :total_pages, :integer, required: true

  def pagination(assigns) do
    ~H"""
    <div class="join">
      <button
        class="join-item btn"
        phx-click="change_page"
        phx-value-page={@current_page - 1}
        disabled={@current_page == 1}
      >
        «
      </button>
      <button class="join-item btn" phx-click="change_page" phx-value-page={1}>
        1
      </button>
      <%= if @current_page > 3 do %>
        <button class="join-item btn btn-disabled">...</button>
      <% end %>

      <%= for page <- max(2, @current_page - 1)..min(@total_pages - 1, @current_page + 1) do %>
        <button
          class={"join-item btn #{if page == @current_page, do: "btn-primary", else: ""}"}
          phx-click="change_page"
          phx-value-page={page}
        >
          <%= page %>
        </button>
      <% end %>

      <%= if @current_page < @total_pages - 2 do %>
        <button class="join-item btn btn-disabled">...</button>
      <% end %>
      <button class="join-item btn" phx-click="change_page" phx-value-page={@total_pages}>
        <%= @total_pages %>
      </button>
      <button
        class="join-item btn"
        phx-click="change_page"
        phx-value-page={@current_page + 1}
        disabled={@current_page == @total_pages}
      >
        »
      </button>
    </div>
    """
  end

  def filters_button(assigns) do
    ~H"""
    <div class="stats stats-vertical shadow mt-2">
      <div class="stat">
        <button class="btn" phx-click="toggle_stats_panel">Filters</button>
        <%= if @supports_touch do %>
          <HomeComponents.pop_up_filters
            :if={@stats_panel_is_open}
            selected_filters={@selected_filters}
          />
        <% else %>
          <HomeComponents.pop_up_mobile
            :if={@stats_panel_is_open}
            selected_filters={@selected_filters}
          />
        <% end %>
      </div>
    </div>
    """
  end
end
