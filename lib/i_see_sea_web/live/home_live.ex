defmodule ISeeSeaWeb.HomeLive do
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
        socket
        |> get_connect_params()
        |> Map.get("supports_touch", false)
      else
        false
      end

    filters = %{
      start_date: Date.to_iso8601(Timex.shift(Date.utc_today(), days: -1)),
      end_date: Date.to_iso8601(Date.utc_today()),
      report_type: "all"
    }

    reports_pagination = %{page_size: 100, page: 1}

    create_report_images = [
      {"jellyfish", "/images/create-report/jellyfish_report.png"},
      {"meteorological", "/images/create-report/meteorological_report.png"},
      {"atypical_activity", "/images/create-report/atypical_report.png"},
      {"pollution", "/images/create-report/pollution_report.png"},
      {"other", "/images/create-report/other_report.png"}
    ]

    # {:ok, reports} = get_reports(Map.values(filters), reports_pagination)
    reports = []

    new_socket =
      assign(socket,
        current_user: socket.assigns.current_user || %{email: "not_logged_in"},
        supports_touch: supports_touch,
        create_report_images: create_report_images,
        filters: to_form(filters),
        reports_pagination: reports_pagination,
        reports: reports,
        create_report_toolbox_is_open: false,
        create_report_type: nil,
        sidebar_open: true,
        form_data: %{username: nil},
        current_view: main_view(),
        is_profile_edit_mode: false,
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
        current_page: 1,
        total_pages: 50,
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
      <div
        id="map"
        class="absolute flex items-center h-full md:mr-52 w-full z-0 rounded-md shadow-md"
        phx-hook="LeafletMap"
        phx-update="ignore"
        data-reports={Jason.encode!(@reports)}
      />

      <%!-- Desktop Design --%>
      <HomeComponents.report_toolbox
        create_report_toolbox_is_open={@create_report_toolbox_is_open}
        create_report_images={@create_report_images}
        create_report_type={@create_report_type}
        supports_touch={@supports_touch}
      />

      <%!-- <div id="sidebar" class="sidebar closed">
        <button class="closebtn" phx-click="toggle_sidebar">Close &#10005;</button>
        <p>Sidebar content goes here.</p>
      </div> --%>
    </div>
    <HomeComponents.stat_home
      supports_touch={@supports_touch}
      filter_menu_is_open={@filter_menu_is_open}
      filters={@filters}
      stats_panel_is_open={@stats_panel_is_open}
    />
    """
  end

  defp get_reports(filters, pagination) do
    with {:ok, _reports, _} <-
           BaseReport.get_with_filter(%{filters: filters}, pagination),
         parsed_reports <- Focus.view(BaseReport.all!(), %Lens{view: Lens.expanded()}) do
      {:ok, parsed_reports}
    end
  end

  @impl true
  def handle_event("change_page", %{"page" => page}, socket) do
    page = String.to_integer(page)
    {:noreply, assign(socket, :current_page, page)}
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
    IO.inspect(!socket.assigns.filter_menu_is_open)
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
  def handle_event("toggle_stats_panel", _params, socket) do
    new_state = !socket.assigns.stats_panel_is_open
    {:noreply, assign(socket, stats_panel_is_open: new_state)}
  end

  @impl true
  def handle_event("add_filter", %{"filter" => filter}, socket) do
    filters =
      if filter in socket.assigns.filters do
        socket.assigns.filters
      else
        [filter | socket.assigns.filters]
      end

    {:noreply, assign(socket, filters: filters)}
  end

  @impl true
  def handle_event("remove_filter", %{"filter" => filter}, socket) do
    filters =
      socket.assigns.filters
      |> Enum.reject(fn f -> f == filter end)

    {:noreply, assign(socket, filters: filters)}
  end

  @impl true
  def handle_event("validate", filters, socket) do
    # Process the filters here
    IO.inspect(filters, label: :handling_validate)
    {:noreply, assign(socket, :filters, format_filters(filters))}
  end

  def handle_info({:updated_event, %{id: "date_range_picker", form: form} = event}, socket) do
    # Extract the updated dates from the event
    # %{
    #   "start_date" => start_date,
    #   "end_date" => end_date,
    #   "report_type" => report_type
    # } = form.params
    IO.inspect(event, label: :event)

    # Process the data (e.g., query the database based on the new filter values)
    # updated_results =
    #   query_database(%{
    #     "start_date" => start_date,
    #     "end_date" => end_date,
    #     "report_type" => report_type
    #   })

    # Update the socket with the new data
    {:noreply, socket}
  end

  # Fallback handle_info for unhandled messages
  def handle_info(msg, socket) do
    IO.inspect(msg, label: "Unhandled message")
    {:noreply, socket}
  end

  defp format_filters(filters) do
    # Extract date range
    date_filter = %{
      field: "date",
      op: "between",
      value: {filters["start_date"], filters["end_date"]}
    }

    # Extract report type
    report_type_filter = %{
      field: "report_type",
      op: "eq",
      value: filters["report_type"]
    }

    # Return the list of filter maps
    [date_filter, report_type_filter]
  end
end
