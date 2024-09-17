defmodule ISeeSeaWeb.HomeComponents do
  @moduledoc false

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
          "z-50 bg-white self-center",
          "md:h-11/12 md:w-1/3 md:m-2 md:self-start",
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
    <textarea
      class="w-full h-40 p-2 border border-gray-300 rounded-md focus:outline-none"
      placeholder="Describe the jaja sighting..."
    ></textarea>
    """
  end

  def create_report_window(%{report_type: ReportType.atypical_activity()} = assigns) do
    ~H"""
    <h2 class="text-2xl font-semibold mb-4">Submit a <%= @report_type %> report</h2>
    <textarea
      class="w-full h-40 p-2 border border-gray-300 rounded-md focus:outline-none"
      placeholder="Describe the jaja sighting..."
    ></textarea>
    """
  end

  def create_report_window(%{report_type: ReportType.meteorological()} = assigns) do
    ~H"""
    <h2 class="text-2xl font-semibold mb-4">Submit a <%= @report_type %> report</h2>
    <textarea
      class="w-full h-40 p-2 border border-gray-300 rounded-md focus:outline-none"
      placeholder="Describe the jaja sighting..."
    ></textarea>
    """
  end

  def create_report_window(%{report_type: ReportType.pollution()} = assigns) do
    ~H"""
    <h2 class="text-2xl font-semibold mb-4">Submit a <%= @report_type %> report</h2>
    <textarea
      class="w-full h-40 p-2 border border-gray-300 rounded-md focus:outline-none"
      placeholder="Describe the jaja sighting..."
    ></textarea>
    """
  end

  def create_report_window(%{report_type: ReportType.other()} = assigns) do
    ~H"""
    <h2 class="text-2xl font-semibold mb-4">Submit a <%= @report_type %> report</h2>
    <textarea
      class="w-full h-40 p-2 border border-gray-300 rounded-md focus:outline-none"
      placeholder="Describe the jaja sighting..."
    ></textarea>
    """
  end

  def create_report_window(assigns) do
    ~H"""
    """
  end
end
