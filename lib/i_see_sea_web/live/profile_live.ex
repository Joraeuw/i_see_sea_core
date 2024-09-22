defmodule ISeeSeaWeb.ProfileLive do
  alias ISeeSea.DB.Models.BaseReport
  use ISeeSeaWeb, :live_view

  alias ISeeSeaWeb.ProfileComponents

  defmacro my_profile_view, do: "my_profile_view"
  defmacro my_reports_view, do: "my_reports_view"

  def profile_views do
    [my_profile_view(), my_reports_view()]
  end

  def render(assigns) do
    ~H"""
    <ProfileComponents.index
      pagination={@pagination}
      view={@profile_view}
      username={@current_user.username}
      email={@current_user.email}
      stats_panel_is_open={@stats_panel_is_open}
      supports_touch={@supports_touch}
      filters={@filters}
      filter_menu_is_open={@filter_menu_is_open}
      user_report_summary={[
        {"jellyfish", "/images/create-report/jellyfish_report.png", 1},
        {"meteorological", "/images/create-report/meteorological_report.png", 10},
        {"atypical_activity", "/images/create-report/atypical_report.png", 12},
        {"pollution", "/images/create-report/pollution_report.png", 51},
        {"other", "/images/create-report/other_report.png", 3}
      ]}
      user_reports={@user_reports}
    />
    """
  end

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

    current_user = socket.assigns.current_user

    report_type = "all"

    filters = %{
      "start_date" => DateTime.to_iso8601(Timex.shift(DateTime.utc_now(), days: -1)),
      "end_date" => DateTime.to_iso8601(DateTime.utc_now()),
      "report_type" => report_type
    }

    reports_pagination = %{page_size: 100, page: 1}

    {:ok, reports} =
      get_user_reports(
        Map.values(%{
          start_date: %{
            "field" => "inserted_at",
            "op" => ">=",
            "value" => Timex.shift(DateTime.utc_now(), days: -1)
          },
          end_date: %{"field" => "inserted_at", "op" => "<=", "value" => DateTime.utc_now()}
        }),
        current_user,
        reports_pagination
      )

    pagination = %{page: 1, total_pages: 10}

    new_socket =
      assign(socket,
        current_user: socket.assigns.current_user,
        supports_touch: supports_touch,
        filters: to_form(filters),
        pagination: pagination,
        reports: reports,
        stats_panel_is_open: true,
        profile_view: my_profile_view(),
        user_reports:
          BaseReport.all!([
            :jellyfish_report,
            :meteorological_report,
            :atypical_activity_report,
            :other_report,
            :pictures,
            :user,
            pollution_report: :pollution_types
          ]),
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
    {:noreply, assign(socket, :page, page)}
  end

  defp get_user_reports(filters, _user, pagination) do
    with {:ok, reports, _} <-
           BaseReport.get_with_filter(%{filters: filters}, pagination),
         parsed_reports <- Focus.view(reports, %Lens{view: Lens.expanded()}) do
      {:ok, parsed_reports}
    end
  end
end
