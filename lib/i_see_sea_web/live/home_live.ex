defmodule ISeeSeaWeb.HomeLive do
  alias ISeeSea.Helpers.Broadcaster
  alias ISeeSea.DB.Logic.ReportOperations
  use ISeeSeaWeb, :live_view

  alias ISeeSea.DB.Models.BaseReport
  alias ISeeSeaWeb.HomeComponents

  defmacro main_view, do: "main_view"
  defmacro my_profile_view, do: "my_profile_view"
  defmacro terms_and_conditions_view, do: "terms_and_conditions_view"
  defmacro privacy_policy_view, do: "privacy_policy_view"

  defmacro profile_view_mode, do: "view"
  defmacro profile_edit_mode, do: "edit"

  def views do
    [main_view(), my_profile_view(), terms_and_conditions_view(), privacy_policy_view()]
  end

  @impl true
  def mount(_params, _session, socket) do
    supports_touch =
      if connected?(socket) do
        # ISeeSeaWeb.Endpoint.subscribe("reports:updates")

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

    create_report_images = [
      {"jellyfish", "/images/create-report/jellyfish_report.png"},
      {"meteorological", "/images/create-report/meteorological_report.png"},
      {"atypical_activity", "/images/create-report/atypical_report.png"},
      {"pollution", "/images/create-report/pollution_report.png"},
      {"other", "/images/create-report/other_report.png"}
    ]

    {:ok, reports, %{page: page} = pagination} =
      ReportOperations.retrieve_reports_with_live_view_filters(
        report_type,
        %{page: 1, page_size: 10},
        filters
      )

    total_pages = ReportOperations.get_total_pages(pagination)
    pagination = %{page: pagination.page, total_pages: total_pages}

    new_socket =
      assign(socket,
        current_user: socket.assigns.current_user || %{email: "not_logged_in"},
        supports_touch: supports_touch,
        create_report_images: create_report_images,
        filters: to_form(filters),
        pagination: pagination,
        reports: reports,
        create_report_toolbox_is_open: false,
        create_report_type: nil,
        sidebar_open: true,
        form_data: %{username: nil},
        current_view: main_view(),
        is_profile_edit_mode: false,
        stats_panel_is_open: not supports_touch,
        filter_menu_is_open: false
      )

    {:ok, new_socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="relative md:inline flex flex-col mt-2 mx-4 md:mx-28 w-10/12 h-full">
      <h1><%= @current_user.email %></h1>
      <div id="map_wrapper" phx-update="ignore">
        <div
          id="map"
          class="absolute flex items-center h-full md:mr-52 w-full z-0 rounded-md shadow-md"
          phx-hook="LeafletMap"
          data-reports={Jason.encode!(Focus.view(@reports, %Lens{view: Lens.expanded()}))}
        />
      </div>

      <%!-- Desktop Design --%>
      <HomeComponents.report_toolbox
        create_report_toolbox_is_open={@create_report_toolbox_is_open}
        create_report_images={@create_report_images}
        create_report_type={@create_report_type}
        supports_touch={@supports_touch}
      />
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
  def handle_event("change_page", %{"page" => page}, socket) do
    page = String.to_integer(page)
    {:noreply, assign(socket, :page, page)}
  end

  @impl true
  def handle_event("navigate", %{"view" => new_view}, socket) do
    if new_view in views() do
      {:noreply, assign(socket, current_view: new_view)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("toggle_stats_panel", _params, socket) do
    {:noreply, assign(socket, :stats_panel_is_open, !socket.assigns.stats_panel_is_open)}
  end

  def handle_event("toggle_filters", _params, socket) do
    {:noreply, assign(socket, :filter_menu_is_open, !socket.assigns.filter_menu_is_open)}
  end

  @impl true
  def handle_event("edit_profile", _params, socket) do
    new_state = !socket.assigns.is_profile_edit_mode
    {:noreply, assign(socket, is_profile_edit_mode: new_state)}
  end

  @impl true
  def handle_event("toggle_sidebar", _params, socket) do
    new_state = !socket.assigns.sidebar_open
    {:noreply, assign(socket, sidebar_open: new_state)}
  end

  @impl true
  def handle_event("toggle_report", %{"type" => report_type}, socket) do
    cond do
      socket.assigns.create_report_type == report_type &&
          socket.assigns.create_report_toolbox_is_open ->
        {:noreply, assign(socket, create_report_toolbox_is_open: false, create_report_type: nil)}

      socket.assigns.create_report_type != report_type &&
          socket.assigns.create_report_toolbox_is_open ->
        {:noreply,
         assign(socket, create_report_toolbox_is_open: true, create_report_type: report_type)}

      not socket.assigns.create_report_toolbox_is_open ->
        {:noreply,
         assign(socket, create_report_toolbox_is_open: true, create_report_type: report_type)}
    end
  end

  def handle_event("exit_dialog", %{"element_id" => element_id}, socket) do
    if(
      element_id in [
        "jellyfish_create_report_button",
        "pollution_create_report_button",
        "meteorological_create_report_button",
        "atypical_activity_create_report_button",
        "other_create_report_button"
      ]
    ) do
      {:noreply, socket}
    else
      {:noreply, assign(socket, create_report_toolbox_is_open: false, create_report_type: nil)}
    end
  end

  @impl true
  def handle_event("set_touch_support", %{"supports_touch" => supports_touch}, socket) do
    {:noreply, assign(socket, :supports_touch, supports_touch)}
  end

  def handle_event("user_selected_location", %{"latitude" => lat, "longitude" => lon}, socket) do
    {:noreply, assign(socket, :user_selected_location, %{lat: lat, lon: lon})}
  end

  @impl true
  def handle_event("filter_reports", filters, socket) do
    {:ok, reports, %{page: page} = pagination} =
      ReportOperations.retrieve_reports_with_live_view_filters(
        filters["report_type"],
        socket.assigns.pagination,
        filters
      )

    total_pages = ReportOperations.get_total_pages(pagination)
    pagination = %{page: page, total_pages: total_pages}

    socket =
      socket
      |> assign(:pagination, pagination)
      |> assign(:reports, reports)
      |> push_event("filters_updated", %{
        stop_live_tracker: false,
        reports: Focus.view(reports, %Lens{view: Lens.expanded()})
      })

    {:noreply, socket}
  end

  def handle_info(%{event: "add_marker", payload: report}, socket) do
    socket = push_event(socket, "add_marker", report)

    {:noreply, socket}
  end
end
