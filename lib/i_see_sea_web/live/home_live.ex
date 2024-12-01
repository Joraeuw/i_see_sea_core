defmodule ISeeSeaWeb.HomeLive do
  alias ISeeSea.DB.Models.User
  alias ISeeSea.DB.Models.BaseReport
  use ISeeSeaWeb, :live_view

  alias ISeeSeaWeb.HomeComponents
  alias ISeeSea.DB.Logic.ReportOperations
  alias ISeeSea.Helpers.DateUtils

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
  def mount(_params, session, socket) do
    locale = Map.get(session, "locale")

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
      "start_date" => DateTime.to_iso8601(Timex.beginning_of_year(DateTime.utc_now())),
      "end_date" => DateTime.to_iso8601(DateTime.utc_now()),
      "report_type" => report_type
    }

    create_report_images = [
      {"jellyfish", "/images/create-report/jellyfish_report.png"},
      {"meteorological", "/images/create-report/meteorological_report.png"},
      {"atypical_activity", "/images/create-report/atypical_report.png"},
      {"pollution", "/images/create-report/pollution_report.png"},
      {"other", "/images/create-report/others1.png"}
    ]

    {:ok, reports, pagination} =
      ReportOperations.retrieve_reports_with_live_view_filters(
        report_type,
        %{page: 1, page_size: 1000},
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
        locale: locale,
        stats: stats,
        is_selecting_location: false,
        current_user: socket.assigns.current_user,
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
        filter_menu_is_open: false,
        user_selected_location: nil
      )

    new_socket = push_event(new_socket, "get_locale", %{})

    {:ok, new_socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="relative md:inline flex flex-col mt-2 mx-4 md:mx-28 w-10/12 h-full">
      <div id="map_wrapper" class="absolute h-full w-full self-start" phx-update="ignore">
        <div
          id="map"
          class="relative flex items-center h-full md:mr-52 w-full z-0 rounded-md shadow-md"
          phx-hook="LeafletMap"
          data-reports={
            Jason.encode!(Focus.view(@reports, %Lens{view: Lens.expanded(), translate: true}))
          }
          data-pin-url="/images/marker-icons/pin.svg"
        />
        <%!-- <img class="absolute top-2 right-3 w-8" src="/images/marker-icons/live.svg" /> --%>
      </div>

      <%!-- Desktop Design --%>

      <div
        class={if !is_user_logged(@current_user), do: "tooltip tooltip-error", else: ""}
        data-tip={
          if !is_user_logged(@current_user), do: translate(@locale, "home.login_first"), else: nil
        }
        data-tooltip-style={if !is_user_logged(@current_user), do: "light", else: nil}
      >
        <HomeComponents.report_toolbox
          create_report_toolbox_is_open={@create_report_toolbox_is_open}
          create_report_images={@create_report_images}
          create_report_type={@create_report_type}
          supports_touch={@supports_touch}
          current_user={@current_user}
          is_selecting_location={@is_selecting_location}
          user_selected_location={@user_selected_location}
          locale={@locale}
        />
      </div>

      <div :if={@is_selecting_location}>translate(@locale,"home.select_location")</div>
    </div>
    <HomeComponents.stat_home
      supports_touch={@supports_touch}
      filters={@filters}
      current_user={@current_user}
      stats_panel_is_open={@stats_panel_is_open}
      data={@stats}
      locale={@locale}
    />

    <ISeeSeaWeb.HomeComponents.image_dialog />
    <ISeeSeaWeb.CommonComponents.filter_dialog filters={@filters} locale={@locale} />
    """
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

  @impl true
  def handle_event("edit_profile", _params, socket) do
    new_state = !socket.assigns.is_profile_edit_mode
    {:noreply, assign(socket, is_profile_edit_mode: new_state)}
  end

  @impl true
  def handle_event("toggle_report", %{"type" => report_type}, socket) do
    if !is_user_logged(socket.assigns.current_user) do
      {:noreply, push_navigate(socket, to: "/login")}
    else
      cond do
        socket.assigns.create_report_type == report_type &&
            socket.assigns.create_report_toolbox_is_open ->
          {:noreply,
           assign(socket, create_report_toolbox_is_open: false, create_report_type: nil)}

        socket.assigns.create_report_type != report_type &&
            socket.assigns.create_report_toolbox_is_open ->
          {:noreply,
           assign(socket, create_report_toolbox_is_open: true, create_report_type: report_type)}

        not socket.assigns.create_report_toolbox_is_open ->
          {:noreply,
           assign(socket, create_report_toolbox_is_open: true, create_report_type: report_type)}
      end
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

  def handle_event("user_selected_location", %{"latitude" => lat, "longitude" => lon} = p, socket) do
    IO.inspect(p, label: :user_selected_location)
    {:noreply, assign(socket, :user_selected_location, %{lat: lat, lon: lon})}
  end

  @impl true
  def handle_event("filter_reports", filters, socket) do
    {:ok, reports, %{total_count: total_count} = pagination} =
      ReportOperations.retrieve_reports_with_live_view_filters(
        filters["report_type"],
        socket.assigns.pagination,
        filters
      )

    stats = %{
      socket.assigns.stats
      | total_entries_in_filter: total_count,
        filter_date_range:
          DateUtils.date_range_display(filters["start_date"], filters["end_date"])
    }

    {:ok, end_date, _} = DateTime.from_iso8601(filters["end_date"])

    stop_live_tracker = Date.compare(Date.utc_today(), end_date) == :lt

    total_pages = ReportOperations.get_total_pages(pagination)
    pagination = Map.put(pagination, :total_pages, total_pages)

    socket =
      socket
      |> assign(:pagination, pagination)
      |> assign(:reports, reports)
      |> assign(:stats, stats)
      |> push_event("filters_updated", %{
        stop_live_tracker: stop_live_tracker,
        reports: Focus.view(reports, %Lens{view: Lens.expanded()})
      })

    {:noreply, socket}
  end

  def handle_event("set_locale", %{"locale" => locale}, socket) do
    {:noreply, assign(socket, :locale, locale)}
  end

  def handle_event("change_locale", %{"locale" => locale}, socket) do
    socket = push_event(socket, "update_locale", %{locale: locale})
    {:noreply, assign(socket, :locale, locale)}
  end

  def handle_info(:select_location, socket) do
    socket =
      socket
      |> push_event("enable_pin_mode", %{})
      |> assign(is_selecting_location: true, create_report_toolbox_is_open: false)

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "add_marker", payload: report}, socket) do
    socket = push_event(socket, "add_marker", report)

    {:noreply, socket}
  end

  def handle_info(%{event: "delete_marker", payload: report}, socket) do
    socket = push_event(socket, "delete_marker", report)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:update_flash, {flash_type, msg}}, socket) do
    socket =
      socket
      |> assign(create_report_toolbox_is_open: false)
      |> put_flash(flash_type, msg)

    {:noreply, socket}
  end

  @impl true
  def handle_info(:location_selected, socket) do
    {:noreply,
     assign(socket,
       create_report_toolbox_is_open: true,
       is_selecting_location: false
     )}
  end
end
