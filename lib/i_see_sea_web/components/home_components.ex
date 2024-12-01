defmodule ISeeSeaWeb.HomeComponents do
  @moduledoc false
  alias ISeeSea.DB.Models.User
  alias ISeeSeaWeb.Live.CreateReportPanel
  alias ISeeSeaWeb.CommonComponents

  use Phoenix.Component

  import ISeeSeaWeb.Trans

  attr :create_report_toolbox_is_open, :boolean, required: true
  attr :supports_touch, :boolean, required: true
  attr :create_report_images, :map, required: true
  attr :create_report_type, :string, required: true
  attr :current_user, :map, required: true
  attr :locale, :string, required: true
  attr :is_selecting_location, :boolean
  attr :user_selected_location, :any

  def report_toolbox(assigns) do
    ~H"""
    <div class="flex flex-col md:flex-row h-full justify-start">
      <%!-- Toolbox --%>
      <div
        id="create-report-toolbox"
        class={[
          "z-20 menu menu-horizontal md:menu-vertical justify-center bg-transparent
          md:bg-base-100 w-auto rounded-md gap-1.5 p-1.5 ml-0 mt-2 transition-all duration-300 ease-in-out group",
          "md:hover:gap-4 md:hover:p-3",
          "md:gird-rows-5 md:grid-cols-1 md:ml-2 md:w-auto md:self-start",
          if(@create_report_toolbox_is_open or @supports_touch, do: "create_report_toolbox_open")
        ]}
      >
        <div :for={{type, image} <- @create_report_images} class="relative">
          <button
            id={"#{type}_create_report_button"}
            class={[
              "relative z-40 flex items-center justify-center self-center overflow-hidden rounded-md
            shadow-sm bg-base-100 shadow-primary-100 transition-all duration-300 ease-in-out aspect-w-1 aspect-h-1 h-14 w-14",
              "md:group-hover:h-16 md:group-hover:w-16",
              if(@create_report_toolbox_is_open or @supports_touch,
                do: "create_report_toolbox_open_button"
              )
            ]}
            phx-click="toggle_report"
            data-type={type}
            phx-value-type={type}
          >
            <img class="p-0 m-0 object-cover w-full h-full pointer-events-none" src={image} />
          </button>
        </div>
      </div>
      <!-- Create Report Panel -->
      <.live_component
        id="create-report-panel-wrapper"
        module={CreateReportPanel}
        create_report_toolbox_is_open={@create_report_toolbox_is_open}
        report_type={@create_report_type}
        is_selecting_location={@is_selecting_location}
        user_selected_location={@user_selected_location}
        current_user={@current_user}
        locale={@locale}
      />
    </div>
    """
  end

  attr :stats_panel_is_open, :boolean, required: true
  attr :supports_touch, :boolean, required: true
  attr :current_user, :map, required: true
  attr :locale, :string, required: true
  attr :data, :map
  attr :filter_menu_is_open, :boolean
  attr :filters, :any

  def stat_home(assigns) do
    ~H"""
    <div class="relative">
      <!-- Stats Panel -->
      <div class={[
        "z-40 fixed top-1/5 right-0 bg-transparent shadow-lg transition-transform duration-500 ease-in-out",
        if(@stats_panel_is_open, do: "translate-x-0", else: "translate-x-[calc(100%+1rem)]")
      ]}>
        <div class={[
          "relative stats stats-vertical overflow-x-hidden overflow-y-hidden shadow mt-2 transition-transform duration-500 ease-in-out",
          if(@stats_panel_is_open, do: "translate-x-0", else: "-translate-x-10")
        ]}>
          <!-- Full Height Toggle Button -->
          <button
            class="absolute top-0 left-0 h-full w-10 bg-base text-black flex items-center
          justify-start z-10 mr-2 transition-transform duration-500 ease-in-out"
            phx-click="toggle_stats_panel"
          >
            <!-- Arrow Icon (SVG) -->
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class={[
                "h-6 w-6 z-30",
                if(@stats_panel_is_open,
                  do: "rotate-180 ease-in-out duration-500",
                  else: "ease-in-out duration-500"
                )
              ]}
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M9 5l7 7-7 7" />
            </svg>
          </button>
          <!-- Stats Content -->
          <div class="stat">
            <CommonComponents.filter_button locale={@locale} />
          </div>
          <div :if={User.is_admin?(@current_user)} class="stat">
            <div class="stat-title"><%= translate(@locale, "home.total_verified_users") %></div>
            <div class="stat-value"><%= @data.verified_users %></div>
          </div>

          <div class="stat">
            <div class="stat-title"><%= translate(@locale, "home.total_reports") %></div>
            <div class="stat-value"><%= @data.total_entries %></div>
            <div class="stat-desc"><%= "#{@data.beginning_of_time} - now" %></div>
          </div>

          <div class="stat">
            <div class="stat-title"><%= translate(@locale, "home.filtered_reports") %></div>
            <div class="stat-value"><%= @data.total_entries_in_filter %></div>
            <div class="stat-desc"><%= @data.filter_date_range %></div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def image_dialog(assigns) do
    ~H"""
    <div id="modal_fullscreen_image_slider" class="modal">
      <div class="modal-box relative overflow-hidden">
        <button class="absolute right-0.5 top-0.5 h-8 w-8 z-50" onclick="closeFullscreenModal()">
          <a class="leaflet-popup-close-button text-2xl z-50" role="button">
            <span class="z-50" arial-hidden="true">×</span>
          </a>
        </button>

        <div class="swiper-container">
          <div class="swiper-wrapper space-x-3" id="modal_fullscreen_image_slider_container">
            <!-- Slides will be injected here by JavaScript -->
          </div>
          <div class="swiper-button-next"></div>
          <div class="swiper-button-prev"></div>
          <div class="swiper-pagination"></div>
        </div>
      </div>
    </div>
    """
  end
end
