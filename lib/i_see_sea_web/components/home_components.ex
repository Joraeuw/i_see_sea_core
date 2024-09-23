defmodule ISeeSeaWeb.HomeComponents do
  @moduledoc false
  alias ISeeSeaWeb.CommonComponents
  alias ISeeSea.Constants
  alias ISeeSea.Constants.StormType
  alias ISeeSea.Constants.JellyfishQuantityRange
  alias ISeeSea.DB.Models.JellyfishSpecies
  alias ISeeSeaWeb.CoreComponents

  use Phoenix.Component

  require ISeeSea.Constants.ReportType, as: ReportType

  attr :create_report_toolbox_is_open, :boolean, required: true
  attr :supports_touch, :boolean, required: true
  attr :create_report_images, :map, required: true
  attr :create_report_type, :string, required: true

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
      <div
        id="create-report-panel"
        data-is-open={@create_report_toolbox_is_open}
        phx-hook="DetectClick"
        class={[
          "z-50 bg-white self-center flex flex-col items-center space-y-3 space-x-5",
          "md:h-11/12 md:max-w-1/3 md:m-2 md:self-start p-3 rounded-md",
          if(not @create_report_toolbox_is_open, do: "hidden")
        ]}
      >
        <.create_report_window report_type={@create_report_type} />
        <textarea class="textarea max-h-40" placeholder="Comment..."></textarea>
        <input type="file" class="file-input w-full max-w-xs" />
        <button class="btn w-full">Submit</button>
      </div>
    </div>
    """
  end

  attr :report_type, :string, required: true

  def create_report_window(%{report_type: ReportType.jellyfish()} = assigns) do
    ~H"""
    <h2 class="text-2xl font-semibold mb-4">Submit a <%= @report_type %> report</h2>
    <input type="text" placeholder="Report Name" class="input w-full max-w-xs" />
    <CoreComponents.selection display_text="Select Species" options={JellyfishSpecies.values()} />
    <CoreComponents.selection display_text="Select Range" options={JellyfishQuantityRange.values()} />
    """
  end

  def create_report_window(%{report_type: ReportType.atypical_activity()} = assigns) do
    ~H"""
    <h2 class="text-2xl font-semibold mb-4">Submit a <%= @report_type %> report</h2>
    <input type="text" placeholder="Report Name" class="input w-full max-w-xs" />
    <CoreComponents.selection display_text="Storm Type" options={StormType.values()} />
    """
  end

  def create_report_window(%{report_type: ReportType.meteorological()} = assigns) do
    ~H"""
    <h2 class="text-2xl font-semibold mb-4">Submit a <%= @report_type %> report</h2>
    <input type="text" placeholder="Report Name" class="input w-full max-w-xs" />
    <CoreComponents.selection display_text="Fog Type" options={Constants.FogType.values()} />
    <CoreComponents.selection display_text="Wind Type" options={Constants.WindType.values()} />
    <CoreComponents.selection display_text="Sea Swell Type" options={Constants.SeaSwellType.values()} />
    """
  end

  def create_report_window(%{report_type: ReportType.pollution()} = assigns) do
    ~H"""
    <h2 class="text-2xl font-semibold mb-4">Submit a <%= @report_type %> report</h2>
    <input type="text" placeholder="Report Name" class="input w-full max-w-xs" />
    <div class="flex flex-row space-x-3">
      <CoreComponents.checkbox text="oil" />
      <CoreComponents.checkbox text="plastic" />
      <CoreComponents.checkbox text="biological" />
    </div>
    """
  end

  def create_report_window(%{report_type: ReportType.other()} = assigns) do
    ~H"""
    <h2 class="text-2xl font-semibold mb-4">Submit a <%= @report_type %> report</h2>
    <input type="text" placeholder="Report Name" class="input w-full max-w-xs" />
    """
  end

  def create_report_window(assigns) do
    ~H"""
    """
  end

  attr :stats_panel_is_open, :boolean, required: true
  attr :supports_touch, :boolean, required: true
  attr :filters, :map, required: true

  def stat_home(assigns) do
    ~H"""
    <div class="relative">
      <!-- Stats Panel -->
      <div class={[
        "z-40 fixed top-1/5 right-0 bg-transparent shadow-lg transition-transform duration-500 ease-in-out",
        if(@stats_panel_is_open, do: "translate-x-0", else: "translate-x-[calc(100%+1rem)]")
      ]}>
        <div class={[
          "relative stats stats-vertical overflow-x-hidden shadow mt-2 transition-transform duration-500 ease-in-out",
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
            <CommonComponents.filter_button filters={@filters} />
          </div>
          <div class="stat">
            <div class="stat-title">Downloads</div>
            <div class="stat-value">31K</div>
            <div class="stat-desc">Jan 1st - Feb 1st</div>
          </div>

          <div class="stat">
            <div class="stat-title">New Users</div>
            <div class="stat-value">4,200</div>
            <div class="stat-desc">↗︎ 400 (22%)</div>
          </div>

          <div class="stat">
            <div class="stat-title">New Registers</div>
            <div class="stat-value">1,200</div>
            <div class="stat-desc">↘︎ 90 (14%)</div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
