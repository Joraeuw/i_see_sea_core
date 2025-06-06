defmodule ISeeSeaWeb.ReportsLive do
  alias ISeeSea.Helpers.DateUtils
  use ISeeSeaWeb, :live_view

  alias ISeeSeaWeb.CommonComponents
  alias ISeeSeaWeb.HomeComponents

  alias ISeeSea.DB.Logic.ReportOperations
  alias ISeeSea.DB.Models.User
  alias ISeeSea.DB.Models.BaseReport

  @impl true
  def mount(_params, _session, socket) do
    supports_touch =
      if connected?(socket) do
        ISeeSeaWeb.Endpoint.subscribe("reports:updates")

        socket
        |> get_connect_params()
        |> Map.get("supports_touch", false)
      else
        false
      end

    report_type = "all"

    filters = %{
      "start_date" => DateTime.to_iso8601(Timex.shift(DateTime.utc_now(), days: -1)),
      "end_date" => DateTime.to_iso8601(DateTime.utc_now()),
      "report_type" => report_type
    }

    reports_pagination = %{page_size: 10, page: 1}

    {:ok, reports, pagination} =
      ReportOperations.retrieve_reports_with_live_view_filters(
        report_type,
        reports_pagination,
        filters
      )

    entries_count = pagination.total_count
    total_pages = ReportOperations.get_total_pages(pagination)
    pagination = Map.put(pagination, :total_pages, total_pages)

    %{beginning_of_time: beginning_of_time, total_entries: total_reports} =
      BaseReport.total_reports()

    stats = %{
      total_entries_in_filter: entries_count,
      total_entries: total_reports,
      beginning_of_time: DateUtils.date_display(beginning_of_time),
      verified_users: User.get_total_verified_users(),
      filter_date_range: DateUtils.date_range_display(filters["start_date"], filters["end_date"])
    }

    new_socket =
      assign(socket,
        current_user: socket.assigns.current_user,
        stats: stats,
        supports_touch: supports_touch,
        stats_panel_is_open: false,
        filters: to_form(filters),
        pagination: pagination,
        reports: reports,
        sidebar_open: true,
        filter_menu_is_open: false
      )

    {:ok, new_socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-start">
      <CommonComponents.pagination pagination={@pagination} />
      <div
        :if={not Enum.empty?(@reports)}
        class="flex flex-wrap justify-center gap-10 py-6 md:px-6 bg-gray-50 rounded-md shadow-md  mt-3 mb-6 w-[calc(100vw-5em)] mx-10 h-auto"
      >
        <%= for %BaseReport{id: report_id} = report <- @reports do %>
          <.live_component
            module={ISeeSeaWeb.ReportCardLiveComponent}
            id={report_id}
            report={report}
            user_is_admin={User.is_admin?(@current_user)}
            locale={@locale}
          />
        <% end %>
      </div>
      <div
        :if={Enum.empty?(@reports)}
        class="flex flex-col items-center justify-center mt-10 p-6 bg-gray-50 border border-gray-200 rounded-md shadow-md"
      >
        <img
          src="/images/report_icons/no_reports_found.svg"
          alt="No Reports"
          class="w-32 h-32 mb-4 opacity-75"
        />
        <p class="text-xl font-semibold text-gray-700">
          <%= translate(@locale, "home.no_reports") %>
        </p>
        <p class="text-sm text-gray-500 mt-2 text-center mb-4">
          <%= translate(@locale, "home.no_matching_reports") %>
        </p>

        <button class="btn w-full" onclick="filter_modal.showModal()">
          <%= translate(@locale, "home.filters") %>
        </button>
      </div>
      <CommonComponents.pagination pagination={@pagination} />
    </div>
    <HomeComponents.stat_home
      data={@stats}
      supports_touch={@supports_touch}
      current_user={@current_user}
      filter_menu_is_open={@filter_menu_is_open}
      filters={@filters}
      stats_panel_is_open={@stats_panel_is_open}
      locale={@locale}
    />

    <ISeeSeaWeb.CommonComponents.filter_dialog filters={@filters} locale={@locale} />
    """
  end

  @impl true
  def handle_event("toggle_stats_panel", _params, socket) do
    {:noreply, assign(socket, :stats_panel_is_open, !socket.assigns.stats_panel_is_open)}
  end

  @impl true
  def handle_event("toggle_filters", _params, socket) do
    {:noreply, assign(socket, :filter_menu_is_open, !socket.assigns.filter_menu_is_open)}
  end

  @impl true
  def handle_event("filter_reports", filters, socket) do
    {:ok, reports, %{total_count: total_count} = pagination} =
      ReportOperations.retrieve_reports_with_live_view_filters(
        filters["report_type"],
        %{page: 1, page_size: socket.assigns.pagination.page_size},
        filters
      )

    stats = %{
      socket.assigns.stats
      | total_entries_in_filter: total_count,
        filter_date_range:
          DateUtils.date_range_display(filters["start_date"], filters["end_date"])
    }

    total_pages = ReportOperations.get_total_pages(pagination)
    pagination = Map.put(pagination, :total_pages, total_pages)

    socket =
      assign(socket,
        reports: reports,
        pagination: pagination,
        filters: to_form(filters),
        stats: stats
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("change_page", %{"page" => page}, socket) do
    page = String.to_integer(page)

    pagination = %{socket.assigns.pagination | page: page}

    {:ok, new_reports, new_pagination} =
      ReportOperations.retrieve_reports_with_live_view_filters(
        socket.assigns.filters.params["report_type"],
        pagination,
        socket.assigns.filters.params
      )

    total_pages = ReportOperations.get_total_pages(new_pagination)
    new_pagination = Map.put(new_pagination, :total_pages, total_pages)

    socket = assign(socket, reports: new_reports, pagination: new_pagination)

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "add_marker", payload: report}, socket) do
    {:noreply, assign(socket, reports: [report | socket.assigns.reports])}
  end

  @impl true
  def handle_info(%{event: "delete_marker", payload: %{report_id: deleted_report_id}}, socket) do
    reports =
      Enum.reject(socket.assigns.reports, fn report ->
        report_id = report[:id] || report[:report_id]
        report_id === String.to_integer(deleted_report_id)
      end)

    {:noreply, assign(socket, reports: reports)}
  end
end
