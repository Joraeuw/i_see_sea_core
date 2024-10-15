defmodule ISeeSeaWeb.CommonComponents do
  alias ISeeSea.Constants.ReportType
  alias ISeeSeaWeb.CoreComponents

  import ISeeSeaWeb.Trans
  use Phoenix.Component

  attr :pagination, :map, required: true

  def pagination(assigns) do
    ~H"""
    <div :if={@pagination.total_pages not in [0, 1] && @pagination.total_pages < 3} class="join">
      <%= for page <- 1..@pagination.total_pages do %>
        <button
          class={"join-item btn #{if page == @pagination.page, do: "btn-primary", else: ""}"}
          phx-click="change_page"
          phx-value-page={page}
          disabled={page == @pagination.page || page > @pagination.total_pages}
        >
          <%= page %>
        </button>
      <% end %>
    </div>

    <div :if={@pagination.total_pages >= 3} class="join">
      <button
        class="join-item btn"
        phx-click="change_page"
        phx-value-page={@pagination.page - 1}
        disabled={@pagination.page == 1}
      >
        «
      </button>
      <button
        class="join-item btn"
        phx-click="change_page"
        phx-value-page={1}
        disabled={@pagination.page == 1}
      >
        1
      </button>
      <%= if @pagination.page > 3 do %>
        <button class="join-item btn btn-disabled">...</button>
      <% end %>

      <%= for page <- max(2, @pagination.page - 1)..min(@pagination.total_pages - 1, @pagination.page + 1) do %>
        <button
          class={"join-item btn #{if page == @pagination.page, do: "btn-primary", else: ""}"}
          phx-click="change_page"
          phx-value-page={page}
          disabled={@pagination.page == page}
        >
          <%= page %>
        </button>
      <% end %>

      <%= if @pagination.page < @pagination.total_pages - 2 do %>
        <button class="join-item btn btn-disabled">...</button>
      <% end %>
      <button
        class="join-item btn"
        phx-click="change_page"
        phx-value-page={@pagination.total_pages}
        disabled={@pagination.page == @pagination.total_pages}
      >
        <%= @pagination.total_pages %>
      </button>
      <button
        class="join-item btn"
        phx-click="change_page"
        phx-value-page={@pagination.page + 1}
        disabled={@pagination.page == @pagination.total_pages}
      >
        »
      </button>
    </div>
    """
  end

  attr :class, :string, default: nil
  attr :locale, :string

  def filter_button(assigns) do
    ~H"""
    <button class={@class || "btn"} onclick="filter_modal.showModal()">
      <%= translate(@locale, "home.filters") %>
    </button>
    """
  end

  attr :filters, :map, required: true
  attr :locale, :string

  def filter_dialog(assigns) do
    ~H"""
    <dialog id="filter_modal" class="modal overflow-visible overflow-y-visible">
      <div class="modal-box fixed overflow-visible bg-white z-30">
        <CoreComponents.simple_form
          for={@filters}
          phx-submit="filter_reports"
          class="flex flex-col items-center mt-10 space-y-8 bg-white"
          onsubmit="document.getElementById('filter_modal').close()"
        >
          <.filter_base name={translate(@locale, "home.date_range")}>
            <div class="relative z-30">
              <CoreComponents.date_range_picker
                id="date_range_picker"
                form={@filters}
                start_date_field={@filters[:start_date]}
                end_date_field={@filters[:end_date]}
                required={true}
              />
            </div>
          </.filter_base>
          <.filter_base name={translate(@locale, "home.report_type")}>
            <CoreComponents.input
              type="select"
              field={@filters[:report_type]}
              options={ReportType.filter_values()}
              value={@filters[:report_type].form.params["report_type"]}
            />
          </.filter_base>
          <:actions>
            <CoreComponents.button
              phx-disable-with={translate(@locale, "home.applying_filters")}
              class="btn"
            >
              Apply
            </CoreComponents.button>
          </:actions>
        </CoreComponents.simple_form>
      </div>
      <form method="dialog" class="modal-backdrop">
        <button class="z-30">hidden button</button>
      </form>
    </dialog>
    """
  end

  attr :name, :string, required: true
  slot :inner_block, required: true

  def filter_base(assigns) do
    ~H"""
    <div class="flex flex-row justify-center align-middle">
      <div class="relative w-72 p-4 border border-gray-400 rounded-md">
        <span class="absolute -top-3 left-4 bg-white px-1 text-gray-500 text-sm"><%= @name %></span>
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
