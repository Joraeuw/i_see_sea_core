defmodule ISeeSeaWeb.CommonComponents do
  alias ISeeSea.Constants.ReportType
  alias ISeeSeaWeb.CoreComponents
  use Phoenix.Component



  # Handling validation event
  @impl true
  def handle_event("validate", %{"current_filters" => filters}, socket) do
    start_date = filters["start_date"]["value"]
    end_date = filters["end_date"]["value"]
    report_type = filters["report_type"]

    # IO.inspect for debugging purposes
    IO.inspect(start_date, label: "Selected Start Date")
    IO.inspect(end_date, label: "Selected End Date")
    IO.inspect(report_type, label: "Selected Report Type")

    # You can perform further validation here, e.g., checking if dates are valid, etc.

  end
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

  def filter_button(assigns) do
    ~H"""
    <button class="btn" onclick="filter_modal.showModal()">Filters</button>
    <dialog id="filter_modal" class="modal overflow-visible overflow-y-visible">
      <div class="modal-box overflow-visible bg-white min-w-72 z-30">
        <CoreComponents.simple_form
          for={@current_filters}
          id="demo_form"
          phx-change="validate"
          phx-submit="save"
        >
          <.filter_base name="Date Range">
            <div class="relative z-30">
              <CoreComponents.date_range_picker
                id="date_range_picker"
                form={@current_filters}
                start_date_field={@current_filters[:start_date]}
                end_date_field={@current_filters[:end_date]}
                required={true}
              />
            </div>
          </.filter_base>
          <.filter_base name="Report Type">
            <select class="select w-full max-w-xs">
              <option selected disabled>Select a report type</option>
              <option :for={type <- ReportType.values()}><%= type %></option>
            </select>
          </.filter_base>
        </CoreComponents.simple_form>
        <div class="modal-action justify-center">
          <form method="dialog">
            <button class="btn">Apply</button>
          </form>
        </div>

        <div class="modal-action">
          <form method="dialog">
            <button class="btn">Close</button>
          </form>
        </div>
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
    <div class="flex flex-row z-30 justify-center align-middle">
      <div class="relative w-72 p-4 border border-gray-400 rounded-md">
        <span class="absolute -top-3 left-4 bg-white px-1 text-gray-500 text-sm"><%= @name %></span>
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
