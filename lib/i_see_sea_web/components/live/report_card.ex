defmodule ISeeSeaWeb.ReportCardLiveComponent do
  use ISeeSeaWeb, :live_component

  alias ISeeSea.DB.Models.Picture
  alias ISeeSea.DB.Models.BaseReport
  alias ISeeSea.DB.Models.JellyfishReport
  alias ISeeSea.DB.Models.AtypicalActivityReport
  alias ISeeSea.DB.Models.PollutionReport
  alias ISeeSea.DB.Models.OtherReport
  alias ISeeSea.DB.Models.MeteorologicalReport
  alias ISeeSea.DB.Models.PollutionType
  import Timex

  @impl true

  def render(assigns) do
    ~H"""
    <div class="relative w-80 h-96 transform transition-transform duration-50s hover:scale-105">
      <div class={[
        "relative transition-transform duration-[0.5] ease-[ease-in-out] transform-style-preserve-3d will-change-transform",
        if(@is_back, do: "rotate-y-180")
      ]}>
        <!-- Front of the card -->
        <div class={[
          "card card-compact relative shadow-sm left-0 top-0 rotate-y-0 backface-hidden",
          if(not @is_back, do: "shadow-md")
        ]}>
          <figure class="object-cover h-48">
            <img
              class="w-full h-full"
              src={Picture.get_uri!(List.first(@pictures, :not_provided))}
              alt="Report Image"
            />
          </figure>
          <div class="card-body relative shadow-md rounded-md h-48">
            <h2 class="card-title w-full line-clamp-1"><%= @name %></h2>
            <p class="line-clamp-3 w-full"><%= @comment %></p>
            <div class="card-actions justify-end">
              <button phx-click="toggle_flip" phx-target={@myself} class="btn btn-primary">
                Details
              </button>
            </div>
          </div>
        </div>
        <!-- Back of the card -->
        <div
          phx-click="toggle_flip"
          phx-target={@myself}
          class={[
            "flex felx-col card absolute bg-base-100 shadow-sm left-0 top-0 rotate-y-180 backface-hidden h-full w-full",
            if(@is_back, do: "shadow-md")
          ]}
        >
          <.back_of_report report={@report} />
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :is_back, false)}
  end

  @impl true
  def handle_event("toggle_flip", _params, socket) do
    {:noreply, assign(socket, :is_back, !socket.assigns.is_back)}
  end

  attr :report, :map, required: true

  defp back_of_report(
         %{
           report: %BaseReport{
             comment: comment,
             report_date: report_date,
             jellyfish_report: %JellyfishReport{quantity: quantity, species_id: species}
           }
         } = assigns
       ) do
    formatted_date = Timex.format!(report_date, "{D} {Mfull} {YYYY}, {h12}:{m} {AM}")

    ~H"""
    <div class="flex flex-col justify-around items-center  h-full w-full">
      <div class="flex flex-row justify-center text-center card-title">Details:</div>
      <div class="flex flex-row items-center w-11/12 p-3 ml-[10px] bg-accent rounded-xl">
        <img class="mr-[10px]" src="/images/report_icons/quintity_icon.svg" />
        <p class="p_card">
          <%= quantity %>
          <p class="opacity-50 text-[0.9em]
        ">Quantity</p>
        </p>
      </div>
      <div class="flex flex-row items-center  p-3 w-11/12 ml-[10px]  bg-accent rounded-xl">
        <img class="mr-[10px]" src="/images/report_icons/jelly_icon.svg" />
        <p class="p_card">
          <%= species %>
          <p class="opacity-50 text-[0.9em]
        ">Species</p>
        </p>
      </div>
      <div class="flex flex-row align-middle p-3 w-11/12 ml-[10px]  bg-accent rounded-xl">
        <div class="felx felx-row h-3/3 w-2/12">
          <img src="/images/report_icons/comment.svg" />
        </div>
        <div class="w-10/12">
          <p class="line-clamp-3"><%= comment %></p>
        </div>
      </div>
      <div class="flex justify-end p-3 w-11/12 mb-[10px] "><%= formatted_date %></div>
    </div>
    """
  end

  defp back_of_report(
         %{
           report: %BaseReport{
             comment: comment,
             report_date: report_date,
             atypical_activity_report: %AtypicalActivityReport{storm_type_id: storm_type}
           }
         } = assigns
       ) do
    formatted_date = Timex.format!(report_date, "{D} {Mfull} {YYYY}, {h12}:{m} {AM}")

    ~H"""
    <div class="flex flex-col justify-around  h-full w-full">
      <div class="flex flex-row justify-center text-center card-title">Details:</div>
      <div class="flex flex-row items-center p-3 w-11/12 ml-[10px] bg-accent rounded-xl">
        <img class="mr-[10px]" src="/images/report_icons/strorm_type.svg" />
        <p class="p_card">
          <%= storm_type %>
          <p class="opacity-50 text-[0.9em]
        ">Storm type</p>
        </p>
      </div>
      <div class="flex flex-row align-middle p-3 w-11/12 ml-[10px] bg-accent rounded-xl">
        <div class="felx felx-row h-3/3 w-1/2">
          <img class="mr-[10px] " src="/images/report_icons/comment.svg" />
        </div>
        <p class="line-clamp-3"><%= comment %></p>
      </div>
      <div class="flex justify-end p-3 w-11/12 mb-[10px]"><%= formatted_date %></div>
    </div>
    """
  end

  defp back_of_report(
         %{
           report: %BaseReport{
             comment: comment,
             report_date: report_date,
             meteorological_report: %MeteorologicalReport{
               fog_type_id: fog_type,
               wind_type_id: wind_type,
               sea_swell_type_id: sea_swell_type
             }
           }
         } = assigns
       ) do
    formatted_date = Timex.format!(report_date, "{D} {Mfull} {YYYY}, {h12}:{m} {AM}")

    ~H"""
    <div class="flex flex-col justify-around align-middle h-full w-full">
      <div class="flex flex-row justify-center text-center card-title">Details:</div>
      <div class="flex flex-row items-center p-3 w-11/12 ml-[10px] bg-accent rounded-xl">
        <img class="mr-[10px]" src="/images/report_icons/fog_type.svg" />
        <p class="p_card">
          <%= fog_type %>
          <p class="opacity-50 text-[0.9em]
        ">Fog type</p>
        </p>
      </div>
      <div class="flex flex-row items-center p-3 w-11/12 ml-[10px] bg-accent rounded-xl">
        <img class="mr-[10px]" src="/images/report_icons/wind_type.svg" />
        <p class="p_card">
          <%= wind_type %>
          <p class="opacity-50 text-[0.9em]
        ">Wind type</p>
        </p>
      </div>
      <div class="flex flex-row items-center p-3 w-11/12 ml-[10px] bg-accent rounded-xl">
        <img class="mr-[10px]" src="/images/report_icons/sea_swell.svg" />
        <p class="p_card">
          <%= sea_swell_type %>
          <p class="opacity-50 text-[0.9em]
        ">Sea swell type</p>
        </p>
      </div>
      <div class="flex flex-row align-middle p-3 w-11/12 ml-[10px] bg-accent rounded-xl">
        <div class="felx felx-row h-3/3 w-1/2">
          <img class="mr-[10px] " src="/images/report_icons/comment.svg" />
        </div>
        <p class="line-clamp-3"><%= comment %></p>
      </div>

      <div class="flex justify-end p-3 w-11/12 mb-[10px]"><%= formatted_date %></div>
    </div>
    """
  end

  defp back_of_report(
         %{
           report: %BaseReport{
             comment: comment,
             report_date: report_date,
             pollution_report: %PollutionReport{pollution_types: pollution_types}
           }
         } = assigns
       ) do
    has_oil = Enum.member?(pollution_types, fn %PollutionType{name: name} -> name === "oil" end)

    has_plastic =
      Enum.member?(pollution_types, fn %PollutionType{name: name} -> name === "plastic" end)

    has_biological =
      Enum.member?(pollution_types, fn %PollutionType{name: name} -> name === "biological" end)

    formatted_date = Timex.format!(report_date, "{D} {Mfull} {YYYY}, {h12}:{m} {AM}")

    ~H"""
    <div class="flex flex-col justify-around align-middle h-full w-full">
      <div class="flex flex-row justify-center text-center card-title">Details:</div>

      <div class="flex flex-row items-center p-3 w-11/12 ml-[10px] bg-accent rounded-xl">
        <img class="mr-[5px] bg-cover" src="/images/report_icons/oil_icon.svg" />

        <p class="p_card">
          <%= if has_oil, do: "Yes", else: "No" %>
          <p class="opacity-50 text-[0.9em]
          ">Oil pollution</p>
        </p>
      </div>

      <div class="flex flex-row items-center p-3 w-11/12 ml-[10px] bg-accent rounded-xl">
        <img class="mr-[5px] bg-cover" src="/images/report_icons/plastic_icon.svg" />
        <p class="p_card">
          <%= if has_plastic, do: "Yes", else: "No" %>
          <p class="opacity-50 justify-end text-[0.9em]
        ">Plas. pollution</p>
        </p>
      </div>
      <div class="flex flex-row items-center p-3 w-11/12 ml-[10px] bg-accent rounded-xl">
        <img class="mr-[10px]" src="/images/report_icons/biological_icon.svg" />
        <p class="p_card">
          <%= if has_biological, do: "Yes", else: "No" %>
          <p class="opacity-50 justify-end text-[0.9em]
        ">Bio. pollution</p>
        </p>
      </div>
      <div class="flex flex-row p-3 w-11/12 ml-[10px] bg-accent rounded-xl">
        <div class="felx felx-row h-3/3 w-1/2">
          <img class="mr-[10px] " src="/images/report_icons/comment.svg" />
        </div>
        <p class="line-clamp-3"><%= comment %></p>
      </div>

      <div class="flex justify-end p-3 w-11/12 mb-[10px]"><%= formatted_date %></div>
    </div>
    """
  end

  defp back_of_report(
         %{
           report: %BaseReport{
             comment: comment,
             report_date: report_date,
             other_report: %OtherReport{}
           }
         } = assigns
       ) do
    formatted_date = Timex.format!(report_date, "{D} {Mfull} {YYYY}, {h12}:{m} {AM}")

    ~H"""
    <div class="flex flex-col justify-around align-middle h-full w-full">
      <div class="flex flex-row justify-center text-center card-title">Details:</div>
      <div class="flex flex-row align-middle p-3 w-11/12 ml-[10px] bg-accent rounded-xl">
        <div class="felx felx-row h-3/3 w-1/2">
          <img class="mr-[10px] " src="/images/report_icons/comment.svg" />
        </div>
        <p class="line-clamp-6"><%= comment %></p>
      </div>
      <div class="flex justify-end w-11/12 mb-[10px]"><%= formatted_date %></div>
    </div>
    """
  end
end
