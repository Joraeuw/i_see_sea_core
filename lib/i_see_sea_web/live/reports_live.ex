defmodule ISeeSeaWeb.ReportsLive do
  alias ISeeSeaWeb.HomeComponents
  alias ISeeSea.DB.Models.BaseReport
  use ISeeSeaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    supports_touch =
      if connected?(socket) do
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

    reports_pagination = %{page_size: 100, page: 1}

    reports =
      BaseReport.all!([
        :jellyfish_report,
        :meteorological_report,
        :atypical_activity_report,
        :other_report,
        :pictures,
        :user,
        pollution_report: :pollution_types
      ])

    new_socket =
      assign(socket,
        supports_touch: supports_touch,
        stats_panel_is_open: false,
        filters: to_form(filters),
        pagination: reports_pagination,
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
      <div class="flex flex-wrap justify-center gap-10 py-6 md:px-6 bg-gray-50 rounded-md shadow-md  mt-3 mb-6 w-[calc(100vw-5em)] mx-10 h-auto">
        <%= for %BaseReport{name: name, comment: comment, pictures: pictures} = report <- @reports do %>
          <!-- Polaroid card container with perspective for 3D effect -->
          <.live_component
            module={ISeeSeaWeb.ReportCardLiveComponent}
            id={report.id}
            name={name}
            comment={comment}
            pictures={pictures}
            report={report}
          />
        <% end %>
      </div>
    </div>
    <HomeComponents.stat_home
      supports_touch={@supports_touch}
      filter_menu_is_open={@filter_menu_is_open}
      filters={@filters}
      stats_panel_is_open={@stats_panel_is_open}
    />
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
end
