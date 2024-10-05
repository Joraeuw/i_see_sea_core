defmodule ISeeSeaWeb.ProfileLive do
  require ISeeSea.Constants.ReportType
  alias ISeeSea.Constants.ReportType
  alias ISeeSea.DB.Logic.ReportOperations
  alias ISeeSea.DB.Models.BaseReport
  use ISeeSeaWeb, :live_view

  import ISeeSeaWeb.Trans
  import ISeeSeaWeb.Gettext

  alias ISeeSeaWeb.ProfileComponents

  defmacro my_profile_view, do: "my_profile_view"
  defmacro my_reports_view, do: "my_reports_view"

  def profile_views do
    [my_profile_view(), my_reports_view()]
  end

  def render(assigns) do
    ~H"""
    <ProfileComponents.index
      locale={@locale}
      pagination={@pagination}
      view={@profile_view}
      username={@current_user.username}
      email={@current_user.email}
      stats_panel_is_open={@stats_panel_is_open}
      supports_touch={@supports_touch}
      filters={@filters}
      filter_menu_is_open={@filter_menu_is_open}
      user_report_summary={@reports_summary}
      reports={@reports}
    />
    """
  end

  @impl true
  def mount(_params, session, socket) do
    supports_touch =
      if connected?(socket) do
        socket
        |> get_connect_params()
        |> Map.get("supports_touch", false)
      else
        false
      end

    current_user = socket.assigns.current_user

    report_type = "all"

    filters = %{
      "start_date" => DateTime.to_iso8601(~U[2024-01-01 00:00:00Z]),
      "end_date" => DateTime.to_iso8601(DateTime.utc_now()),
      "report_type" => report_type
    }

    {:ok, reports, pagination} =
      get_user_reports(current_user, report_type, filters)

    locale = Map.get(session, "preferred_locale") || "bg"

    all_report_types = [
      {ReportType.jellyfish(), "/images/create-report/jellyfish_report.png"},
      {ReportType.meteorological(), "/images/create-report/meteorological_report.png"},
      {ReportType.atypical_activity(), "/images/create-report/atypical_report.png"},
      {ReportType.pollution(), "/images/create-report/pollution_report.png"},
      {ReportType.other(), "/images/create-report/other_report.png"}
    ]

    grouped_reports = reports |> Enum.group_by(& &1.report_type)

    summary =
      all_report_types
      |> Enum.map(fn {type, image_path} ->
        count = grouped_reports |> Map.get(type, []) |> length()
        {type, image_path, count}
      end)

    new_socket =
      assign(socket,
        locale: locale,
        current_user: current_user,
        supports_touch: supports_touch,
        filter_report_type: report_type,
        filters: to_form(filters),
        pagination: pagination,
        reports: reports,
        reports_summary: summary,
        stats_panel_is_open: true,
        profile_view: my_profile_view(),
        filter_menu_is_open: false
      )

    {:ok, new_socket}
  end

  @impl true
  def handle_event("toggle_profile_view", %{"view" => view}, socket) do
    if view in profile_views() do
      {:noreply, assign(socket, profile_view: view)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("toggle_stats_panel", _params, socket) do
    new_state = !socket.assigns.stats_panel_is_open
    {:noreply, assign(socket, stats_panel_is_open: new_state)}
  end

  @impl true
  def handle_event("change_page", %{"page" => page}, socket) do
    page = String.to_integer(page)

    pagination = %{socket.assigns.pagination | page: page}

    {:ok, new_reports, new_pagination} =
      get_user_reports(
        socket.assigns.current_user,
        socket.assigns.filters["report_type"],
        socket.assigns.filters.params,
        pagination
      )

    socket = assign(socket, reports: new_reports, pagination: new_pagination)

    {:noreply, socket}
  end

  @impl true
  def handle_event("show_specific_reports", %{"report_type" => type}, socket) do
    filters = %{
      "start_date" => DateTime.to_iso8601(~U[2024-01-01 00:00:00Z]),
      "end_date" => DateTime.to_iso8601(DateTime.utc_now()),
      "report_type" => type
    }

    {:ok, reports, pagination} =
      get_user_reports(socket.assigns.current_user, type, filters)

    socket =
      assign(socket, pagination: pagination, reports: reports, profile_view: my_reports_view())

    {:noreply, socket}
  end

  @impl true
  def handle_event("filter_reports", filters, socket) do
    {:ok, reports, pagination} =
      get_user_reports(socket.assigns.current_user, filters["report_type"], filters)

    socket = assign(socket, pagination: pagination, reports: reports, filters: to_form(filters))

    {:noreply, socket}
  end

  defp get_user_reports(
         current_user,
         report_type,
         filters,
         pagination \\ %{page: 1, page_size: 10}
       ) do
    {:ok, reports, pagination} =
      ReportOperations.retrieve_user_reports_with_live_view_filters(
        current_user,
        report_type,
        pagination,
        filters
      )

    total_pages = ReportOperations.get_total_pages(pagination)
    pagination = Map.put(pagination, :total_pages, total_pages)

    {:ok, reports, pagination}
  end
end
