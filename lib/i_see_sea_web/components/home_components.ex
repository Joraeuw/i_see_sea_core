defmodule ISeeSeaWeb.HomeComponents do
  @moduledoc false
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
          "md:hover:gap-6 md:hover:p-4",
          "md:gird-rows-5 md:grid-cols-1 md:ml-2 md:w-auto md:self-start",
          if(@create_report_toolbox_is_open or @supports_touch, do: "create_report_toolbox_open")
        ]}
      >
        <div :for={{type, image} <- @create_report_images} class="relative">
          <button
            id={"#{type}_create_report_button"}
            class={[
              "relative z-40 flex items-center justify-center self-center overflow-hidden rounded-md
            shadow-sm shadow-primary-100 transition-all duration-300 ease-in-out aspect-w-1 aspect-h-1 h-14 w-14",
              "md:group-hover:h-20 md:group-hover:w-20",
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
        phx-hook="DetectClick"
        class={[
          "z-50 bg-white self-center flex flex-col items-center space-y-3 space-x-5",
          "md:h-11/12 md:max-w-1/3 md:m-2 md:self-start p-3 rounded-md",
          if(not @create_report_toolbox_is_open, do: "hidden")
        ]}
      >
        <.create_report_window report_type={@create_report_type} />
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
    <textarea class="textarea" placeholder="Comment..."></textarea>
    <input type="file" class="file-input w-full max-w-xs" />
    """
  end

  def create_report_window(%{report_type: ReportType.atypical_activity()} = assigns) do
    ~H"""
    <h2 class="text-2xl font-semibold mb-4">Submit a <%= @report_type %> report</h2>
    <input type="text" placeholder="Report Name" class="input w-full max-w-xs" />
    <CoreComponents.selection display_text="Storm Type" options={StormType.values()} />
    <textarea class="textarea" placeholder="Comment..."></textarea>
    <input type="file" class="file-input w-full max-w-xs" />
    """
  end

  def create_report_window(%{report_type: ReportType.meteorological()} = assigns) do
    ~H"""
    <h2 class="text-2xl font-semibold mb-4">Submit a <%= @report_type %> report</h2>
    <input type="text" placeholder="Report Name" class="input w-full max-w-xs" />
    <CoreComponents.selection display_text="Fog Type" options={Constants.FogType.values()} />
    <CoreComponents.selection display_text="Wind Type" options={Constants.WindType.values()} />
    <CoreComponents.selection display_text="Sea Swell Type" options={Constants.SeaSwellType.values()} />
    <textarea class="textarea" placeholder="Comment..."></textarea>
    <input type="file" class="file-input w-full max-w-xs" />
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
    <textarea class="textarea" placeholder="Comment..."></textarea>
    <input type="file" class="file-input w-full max-w-xs" />
    """
  end

  def create_report_window(%{report_type: ReportType.other()} = assigns) do
    ~H"""
    <h2 class="text-2xl font-semibold mb-4">Submit a <%= @report_type %> report</h2>
    <input type="text" placeholder="Report Name" class="input w-full max-w-xs" />
    <textarea class="textarea" placeholder="Comment..."></textarea>
    <input type="file" class="file-input w-full max-w-xs" />
    """
  end

  def create_report_window(assigns) do
    ~H"""
    """
  end
  attr :stats_panel_is_open, :boolean, required: true
  attr :selected_filter, :list, required: true
  def pop_up_filters(assigns) do
    ~H"""

    <div
      id="stats-panel"
      class="hidden md:flex flex-col absolute justify-between top-3 right-52 bg-white w-3/12 h-8/12 shadow-lg p-4 z-50"
    >

    <%= if length(@selected_filters) > 0 do %>
    <div class="border-dotted border-2 border-gray-400 p-2 mb-2">
      <h2 class="font-bold">Selected Filters:</h2>
      <ul>
        <%= for filter <- @selected_filters do %>
          <li class="flex items-center mb-1">
            <span><%= filter %></span>
            <button
              class="ml-2 text-red-500 hover:text-red-700"
              phx-click="remove_filter"
              phx-value-filter={filter}
            >
              &times;
            </button>
          </li>
        <% end %>
      </ul>
    </div>
  <% end %>

      <div class="dropdown">
        <div tabindex="0" role="button" class="btn m-1">Add filter</div>
        <ul
          tabindex="0"
          class="dropdown-content menu bg-base-100 rounded-box z-30 w-52 p-2 shadow max-h-48 overflow-y-auto"
        >
          <div class="font-bold">
            <h1>Report type</h1>
          </div>
          <li><a phx-click="add_filter" phx-value-filter="jellyfish">Jellyfish</a></li>
          <li><a phx-click="add_filter" phx-value-filter="meteorological">Meteorological</a></li>
          <li><a phx-click="add_filter" phx-value-filter="pollution">Pollution</a></li>
          <li><a phx-click="add_filter" phx-value-filter="atypical">Atypical</a></li>
          <li><a phx-click="add_filter" phx-value-filter="other">Other</a></li>

          <div class="font-bold">
            <h1>Filter by:</h1>
          </div>
          <li><a>name</a></li>
          <li><a>quantity</a></li>
          <li><a>species</a></li>
          <li><a>pollution_types</a></li>
          <li><a>fog_type</a></li>
          <li><a>wind_type</a></li>
          <li><a>sea_swell_type</a></li>
          <li><a>deleted</a></li>
          <li><a>inserted_at</a></li>

          <div class="font-bold">
            <h1>Sortable</h1>
          </div>
          <li><a>id</a></li>
          <li><a>name</a></li>
          <li><a>report_date</a></li>
          <li><a>quantity</a></li>
          <li><a>species</a></li>
          <li><a>fog_type</a></li>
          <li><a>wind_type</a></li>
          <li><a>sea_swell_type</a></li>
          <li><a>inserted_at</a></li>
        </ul>
      </div>

      <button class="btn btn-secondary mt-4" phx-click="toggle_stats_panel">Close</button>
    </div>

    """
  end
  attr :stats_panel_is_open, :boolean, required: true
  attr :selected_filter, :list, required: true
def pop_up_mobile(assigns) do
  ~H"""
  <button class="btn" onclick="my_modal_2.showModal()">open modal</button>
  <dialog id="my_modal_2" class="modal h-11/12">
    <div class="modal-box">
    <%= if length(@selected_filters) > 0 do %>
      <div class="border-dotted border-2 border-gray-400 p-2 mb-2">
        <h2 class="font-bold">Selected Filters:</h2>
        <ul>
          <%= for filter <- @selected_filters do %>
            <li class="flex items-center mb-1">
              <span><%= filter %></span>
              <button
                class="ml-2 text-red-500 hover:text-red-700"
                phx-click="remove_filter"
                phx-value-filter={filter}
              >
                &times;
              </button>
            </li>
          <% end %>
        </ul>
      </div>
    <% end %>
    <div class="dropdown">
          <div tabindex="0" role="button" class="btn m-1">Add filter</div>
          <ul
            tabindex="0"
            class="dropdown-content menu bg-base-100 rounded-box z-30 w-52 p-2 shadow max-h-48 overflow-y-auto"
          >
            <div class="font-bold">
              <h1>Report type</h1>
            </div>
            <li><a phx-click="add_filter" phx-value-filter="jellyfish">Jellyfish</a></li>
            <li><a phx-click="add_filter" phx-value-filter="meteorological">Meteorological</a></li>
            <li><a phx-click="add_filter" phx-value-filter="pollution">Pollution</a></li>
            <li><a phx-click="add_filter" phx-value-filter="atypical">Atypical</a></li>
            <li><a phx-click="add_filter" phx-value-filter="other">Other</a></li>

            <div class="font-bold">
              <h1>Filter by:</h1>
            </div>
            <li><a>name</a></li>
            <li><a>quantity</a></li>
            <li><a>species</a></li>
            <li><a>pollution_types</a></li>
            <li><a>fog_type</a></li>
            <li><a>wind_type</a></li>
            <li><a>sea_swell_type</a></li>
            <li><a>deleted</a></li>
            <li><a>inserted_at</a></li>

            <div class="font-bold">
              <h1>Sortable</h1>
            </div>
            <li><a>id</a></li>
            <li><a>name</a></li>
            <li><a>report_date</a></li>
            <li><a>quantity</a></li>
            <li><a>species</a></li>
            <li><a>fog_type</a></li>
            <li><a>wind_type</a></li>
            <li><a>sea_swell_type</a></li>
            <li><a>inserted_at</a></li>
          </ul>
          <button class="btn btn-secondary mt-4" phx-click="toggle_stats_panel">Close</button>
        </div>

    </div>
    <form method="dialog" class="modal-backdrop">
      <button>close</button>
    </form>
  </dialog>
  """

end
  attr :stats_panel_is_open, :boolean, required: true
  attr :selected_filter, :list, required: true
  attr :supports_touch, :boolean, required: true
  def stat_home(assigns) do
    ~H"""
    <div class="stats stats-vertical shadow mt-2">
    <div class="stat">
        <button class="btn" phx-click="toggle_stats_panel"> Filters</button>
        <%= if @supports_touch do %>
        <.pop_up_filters :if={@stats_panel_is_open} selected_filters={@selected_filters}/>
        <% else %>
        <.pop_up_mobile :if={@stats_panel_is_open} selected_filters={@selected_filters}/>
        <% end %>


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
    """
  end
end
