defmodule ISeeSeaWeb.HomeLive do
  alias ISeeSea.DB.Logic.ReportOperations
  alias ISeeSeaWeb.ProfileComponents
  use ISeeSeaWeb, :live_view

  alias ISeeSea.DB.Models.BaseReport
  alias ISeeSeaWeb.HomeComponents

  defmacro main_view, do: "main_view"
  defmacro my_profile_view, do: "my_profile_view"

  defmacro my_profile_subview, do: "my_profile_subview"
  defmacro my_reports_subview, do: "my_reports_subview"

  defmacro profile_view_mode, do: "view"
  defmacro profile_edit_mode, do: "edit"

  def views do
    [main_view(), my_profile_view()]
  end

  def profile_subviews do
    [my_profile_subview(), my_reports_subview()]
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

    map_filters = [
      %{
        "field" => "inserted_at",
        "op" => ">=",
        "value" => Timex.shift(DateTime.utc_now(), days: -1)
      },
      %{"field" => "inserted_at", "op" => "<=", "value" => DateTime.utc_now()}
    ]

    reports_pagination = %{page_size: 100, page: 1}

    create_report_images = [
      {"jellyfish", "/images/create-report/jellyfish.jpeg"},
      {"meteorological", "/images/create-report/storm.jpeg"},
      {"atypical_activity", "/images/create-report/atypical_wether.jpeg"},
      {"pollution", "/images/create-report/pollution.jpeg"},
      {"other", "/images/create-report/pollution.jpeg"}
    ]

    {:ok, reports} = get_reports(map_filters, reports_pagination)

    new_socket =
      assign(socket,
        supports_touch: supports_touch,
        create_report_images: create_report_images,
        map_filters: map_filters,
        reports_pagination: reports_pagination,
        reports: reports,
        create_report_toolbox_is_open: false,
        create_report_type: nil,
        sidebar_open: true,
        form_data: %{username: nil},
        current_view: main_view(),
        profile_subview: my_profile_subview(),
        is_profile_edit_mode: false,
        user_reports: BaseReport.all!(),
        current_page: 1,
        total_pages: 50,
        stats_panel_is_open: false,
        selected_filters: []
      )

    {:ok, new_socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="relative md:inline flex flex-col mt-2 mx-4 md:mx-28 w-7/12 h-full">
      <div
        :if={@current_view === main_view()}
        id="map"
        class="absolute flex items-center h-full w-full z-0 rounded-md shadow-md"
        phx-hook="LeafletMap"
        phx-update="ignore"
        data-reports={Jason.encode!(@reports)}
      />

      <%!-- Desktop Design --%>
      <HomeComponents.report_toolbox
        :if={@current_view === main_view()}
        create_report_toolbox_is_open={@create_report_toolbox_is_open}
        create_report_images={@create_report_images}
        create_report_type={@create_report_type}
        supports_touch={@supports_touch}
      />

      <ProfileComponents.index
        :if={@current_view === my_profile_view()}
        current_page={@current_page}
        total_pages={@total_pages}
        subview={@profile_subview}
        is_edit_mode={@is_profile_edit_mode}
        email="myemail@abv.bg"
        username="My Username"
        user_report_summary={[
          {"jellyfish", "/images/create-report/jellyfish.jpeg", 2},
          {"jellyfish", "/images/create-report/jellyfish.jpeg", 2},
          {"jellyfish", "/images/create-report/jellyfish.jpeg", 2},
          {"jellyfish", "/images/create-report/jellyfish.jpeg", 2},
          {"jellyfish", "/images/create-report/jellyfish.jpeg", 2},
          {"jellyfish", "/images/create-report/jellyfish.jpeg", 2}
        ]}
        user_reports={@user_reports}
      />
      <%!-- <div id="sidebar" class="sidebar closed">
        <button class="closebtn" phx-click="toggle_sidebar">Close &#10005;</button>
        <p>Sidebar content goes here.</p>
      </div> --%>
    </div>

    <HomeComponents.stat_home
      supports_touch={@supports_touch}
      stats_panel_is_open={@stats_panel_is_open}
      selected_filters={@selected_filters}
    />
    """
  end

  defp get_reports(filters, pagination) do
    with {:ok, reports, _} <-
           BaseReport.get_with_filter(%{filters: filters}, pagination),
         parsed_reports <- Focus.view(reports, %Lens{view: Lens.expanded()}) do
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
    IO.inspect(new_view)

    if new_view in views() do
      {:noreply, assign(socket, current_view: new_view)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("toggle_profile_subview", %{"subview" => subview}, socket) do
    if subview in profile_subviews() do
      {:noreply, assign(socket, profile_subview: subview)}
    else
      {:noreply, socket}
    end
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

  @impl true
  def handle_event("stop_creating_report", %{"element_id" => element_id}, socket) do
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
    selected_filters =
      if filter in socket.assigns.selected_filters do
        socket.assigns.selected_filters
      else
        [filter | socket.assigns.selected_filters]
      end

    {:noreply, assign(socket, selected_filters: selected_filters)}
  end

  @impl true
  def handle_event("remove_filter", %{"filter" => filter}, socket) do
    selected_filters =
      socket.assigns.selected_filters
      |> Enum.reject(fn f -> f == filter end)

    {:noreply, assign(socket, selected_filters: selected_filters)}
  end

  @impl true
  def handle_event("remove_filter", %{"filter" => filter}, socket) do
    selected_filters =
      socket.assigns.selected_filters
      |> Enum.reject(fn f -> f == filter end)

    {:noreply, assign(socket, selected_filters: selected_filters)}
  end
end
