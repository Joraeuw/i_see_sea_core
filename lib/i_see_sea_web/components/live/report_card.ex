defmodule ISeeSeaWeb.ReportCardLiveComponent do
  use ISeeSeaWeb, :live_component

  alias ISeeSea.DB.Models.Picture
  alias ISeeSea.Helpers.Broadcaster
  alias ISeeSea.DB.Models.BaseReport
  alias ISeeSea.DB.Models.PollutionType

  @impl true

  def render(assigns) do
    ~H"""
    <div
      id={"report-card-#{@report.id}"}
      class="relative w-80 h-96 transform transition-transform duration-50s hover:scale-105"
    >
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
              src={Picture.get_uri!(List.first(@report.pictures, :not_provided))}
              alt="Report Image"
            />
          </figure>
          <div class="card-body relative shadow-md rounded-md h-48">
            <h2 class="card-title w-full line-clamp-1"><%= @report.name %></h2>
            <p class="line-clamp-3 w-full"><%= @report.comment %></p>
            <div class="card-actions grid grid-cols-12 gap-2 w-full">
              <button
                phx-click="toggle_flip"
                phx-target={@myself}
                class={"btn btn-primary " <> (if @user_is_admin, do: "col-span-9", else: "col-span-12")}
              >
                <%= translate(@locale, "see_report.details") %>
              </button>

              <%= if @user_is_admin do %>
                <button
                  phx-click="delete_report"
                  phx-target={@myself}
                  phx-value-report-id={@report.id}
                  class="btn_delete flex items-center justify-center col-span-3"
                >
                  <img class="bg-contain h-[31px] w-[36px]" src="/images/report_icons/trash_icon.svg" />
                </button>
              <% end %>
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
          <.back_of_report report={@report} locale={@locale} />
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, assign(socket, is_back: false)}
  end

  @impl true
  def update(assigns, socket) do
    user_is_admin = Map.get(assigns, :user_is_admin, false)
    {:ok, assign(socket, Map.put(assigns, :user_is_admin, user_is_admin))}
  end

  @impl true
  def handle_event("toggle_flip", _params, socket) do
    {:noreply, assign(socket, :is_back, !socket.assigns.is_back)}
  end

  @impl true
  def handle_event("delete_report", %{"report-id" => report_id}, socket) do
    case BaseReport.soft_delete(report_id) do
      {:ok, _} ->
        Broadcaster.broadcast!("reports:updates", "delete_marker", %{report_id: report_id})

        socket =
          socket
          |> put_flash(:info, translate(socket.assigns.locale, "common.report_deleted"))

        {:noreply, socket}

      {:error, :not_found, BaseReport} ->
        socket =
          socket
          |> put_flash(:error, translate(socket.assigns.locale, "common.report_not_found"))

        {:noreply, socket}
    end
  end

  defp back_of_report(%{report: report, locale: locale} = assigns) do
    formatted_date = Timex.format!(report.report_date, "{D} {Mfull} {YYYY}, {h12}:{m} {AM}")
    comment = report.comment || ""

    cond do
      # Jellyfish Report
      Ecto.assoc_loaded?(report.jellyfish_report) and not is_nil(report.jellyfish_report) ->
        jellyfish_report = report.jellyfish_report
        quantity = jellyfish_report.quantity || "N/A"
        species_id = jellyfish_report.species_id || "unknown"
        species_name = translate(locale, "jellyfish_report.species.#{species_id}")

        ~H"""
        <div class="flex flex-col justify-around items-center h-full w-full">
          <div class="flex flex-row justify-center text-center card-title">
            <% translate(@locale, "create_report.details") %>
          </div>
          <div class="flex flex-row items-center w-11/12 p-3 ml-[10px] bg-accent rounded-xl">
            <img class="mr-[10px]" src="/images/report_icons/quintity_icon.svg" />
            <p class="p_card">
              <%= quantity %>
              <p class="opacity-50 text-[0.9em]"><% translate(@locale, "create_report.quantity") %></p>
            </p>
          </div>
          <div class="flex flex-row items-center p-3 w-11/12 ml-[10px] bg-accent rounded-xl">
            <img class="mr-[10px]" src="/images/report_icons/jelly_icon.svg" />
            <p class="p_card">
              <%= species_name %>
              <p class="opacity-50 text-[0.9em]"><% translate(@locale, "create_report.species") %></p>
            </p>
          </div>
          <div class="flex flex-row p-3 w-11/12 ml-[10px] bg-accent rounded-xl">
            <div class="flex flex-row h-3/3 w-2/12">
              <img src="/images/report_icons/comment.svg" />
            </div>
            <div class="w-10/12">
              <p class="line-clamp-3"><%= comment %></p>
            </div>
          </div>
          <div class="flex justify-end p-3 w-11/12 mb-[10px]"><%= formatted_date %></div>
        </div>
        """

      # Atypical Activity Report
      Ecto.assoc_loaded?(report.atypical_activity_report) and
          not is_nil(report.atypical_activity_report) ->
        aar = report.atypical_activity_report
        storm_type_id = aar.storm_type_id || "unknown"

        storm_type_name =
          translate(locale, "atypical_activity_report.storm_type.#{storm_type_id}")

        ~H"""
        <div class="flex flex-col justify-around h-full w-full">
          <div class="flex flex-row justify-center text-center card-title">
            <% translate(@locale, "create_report.details") %>
          </div>
          <div class="flex flex-row items-center p-3 w-11/12 ml-[10px] bg-accent rounded-xl">
            <img class="mr-[10px]" src="/images/report_icons/storm_type.svg" />
            <p class="p_card">
              <%= storm_type_name %>
              <p class="opacity-50 text-[0.9em]"><% translate(@locale, "create_report.storm_type") %></p>
            </p>
          </div>
          <div class="flex flex-row p-3 w-11/12 ml-[10px] bg-accent rounded-xl">
            <div class="flex flex-row h-3/3 w-2/12">
              <img class="mr-[10px]" src="/images/report_icons/comment.svg" />
            </div>
            <div class="w-10/12">
              <p class="line-clamp-3"><%= comment %></p>
            </div>
          </div>
          <div class="flex justify-end p-3 w-11/12 mb-[10px]"><%= formatted_date %></div>
        </div>
        """

      # Meteorological Report
      Ecto.assoc_loaded?(report.meteorological_report) and
          not is_nil(report.meteorological_report) ->
        mr = report.meteorological_report
        fog_type_id = mr.fog_type_id || "unknown"
        wind_type_id = mr.wind_type_id || "unknown"
        sea_swell_type_id = mr.sea_swell_type_id || "unknown"

        fog_type_name = translate(locale, "meteorological_report.fog_type.#{fog_type_id}")
        wind_type_name = translate(locale, "meteorological_report.wind_type.#{wind_type_id}")

        sea_swell_type_name =
          translate(locale, "meteorological_report.sea_swell_type.#{sea_swell_type_id}")

        ~H"""
        <div class="flex flex-col justify-around align-middle h-full w-full">
          <div class="flex flex-row justify-center text-center card-title">
            <% translate(@locale, "create_report.details") %>
          </div>
          <div class="flex flex-row items-center p-3 w-11/12 ml-[10px] bg-accent rounded-xl">
            <img class="mr-[10px]" src="/images/report_icons/fog_type.svg" />
            <p class="p_card">
              <%= fog_type_name %>
              <p class="opacity-50 text-[0.9em]"><% translate(@locale, "create_report.fog_type") %></p>
            </p>
          </div>
          <div class="flex flex-row items-center p-3 w-11/12 ml-[10px] bg-accent rounded-xl">
            <img class="mr-[10px]" src="/images/report_icons/wind_type.svg" />
            <p class="p_card">
              <%= wind_type_name %>
              <p class="opacity-50 text-[0.9em]"><% translate(@locale, "create_report.wind_type") %></p>
            </p>
          </div>
          <div class="flex flex-row items-center p-3 w-11/12 ml-[10px] bg-accent rounded-xl">
            <img class="mr-[10px]" src="/images/report_icons/sea_swell.svg" />
            <p class="p_card">
              <%= sea_swell_type_name %>
              <p class="opacity-50 text-[0.9em]"><% translate(@locale, "create_report.ss_type") %></p>
            </p>
          </div>
          <div class="flex flex-row p-3 w-11/12 ml-[10px] bg-accent rounded-xl">
            <div class="flex flex-row h-3/3 w-2/12">
              <img class="mr-[10px]" src="/images/report_icons/comment.svg" />
            </div>
            <div class="w-10/12">
              <p class="line-clamp-3"><%= comment %></p>
            </div>
          </div>
          <div class="flex justify-end p-3 w-11/12 mb-[10px]"><%= formatted_date %></div>
        </div>
        """

      # Pollution Report
      Ecto.assoc_loaded?(report.pollution_report) and not is_nil(report.pollution_report) ->
        pr = report.pollution_report

        pollution_types =
          if Ecto.assoc_loaded?(pr.pollution_types), do: pr.pollution_types, else: []

        pollution_types = pollution_types || []

        has_oil = Enum.any?(pollution_types, fn %PollutionType{name: name} -> name == "oil" end)

        has_plastic =
          Enum.any?(pollution_types, fn %PollutionType{name: name} -> name == "plastic" end)

        has_biological =
          Enum.any?(pollution_types, fn %PollutionType{name: name} -> name == "biological" end)

        ~H"""
        <div class="flex flex-col justify-around align-middle h-full w-full">
          <div class="flex flex-row justify-center text-center card-title">
            <% translate(@locale, "create_report.details") %>
          </div>
          <div class="flex flex-row items-center p-3 w-11/12 ml-[10px] bg-accent rounded-xl">
            <img class="mr-[5px] bg-cover" src="/images/report_icons/oil_icon.svg" />
            <p class="p_card">
            <%= if has_oil do %>
                <%= translate(locale, "pollution_report.yes") %>
            <% else %>
                <%= translate(locale, "pollution_report.no") %>
            <% end %>
              <p class="opacity-50 text-[0.9em]">
                <% translate(@locale, "create_report.oil_pollution") %>
              </p>
            </p>
          </div>
          <div class="flex flex-row items-center p-3 w-11/12 ml-[10px] bg-accent rounded-xl">
            <img class="mr-[5px] bg-cover" src="/images/report_icons/plastic_icon.svg" />
            <p class="p_card">
            <%= if has_plastic do %>
                <%= translate(locale, "pollution_report.yes") %>
            <% else %>
                <%= translate(locale, "pollution_report.no") %>
            <% end %>

              <p class="opacity-50 text-[0.9em]">
                <% translate(@locale, "create_report.plastic_pollution") %>
              </p>
            </p>
          </div>
          <div class="flex flex-row items-center p-3 w-11/12 ml-[10px] bg-accent rounded-xl">
            <img class="mr-[10px]" src="/images/report_icons/biological_icon.svg" />
            <p class="p_card">
            <%= if has_biological do %>
                <%= translate(locale, "pollution_report.yes") %>
            <% else %>
                <%= translate(locale, "pollution_report.no") %>
            <% end %>
              <p class="opacity-50 text-[0.9em]">
                <% translate(@locale, "create_report.biological_pollution") %>
              </p>
            </p>
          </div>
          <div class="flex flex-row p-3 w-11/12 ml-[10px] bg-accent rounded-xl">
            <div class="flex flex-row h-3/3 w-2/12">
              <img class="mr-[10px]" src="/images/report_icons/comment.svg" />
            </div>
            <div class="w-10/12">
              <p class="line-clamp-3"><%= comment %></p>
            </div>
          </div>
          <div class="flex justify-end p-3 w-11/12 mb-[10px]"><%= formatted_date %></div>
        </div>
        """

      # Other Report
      Ecto.assoc_loaded?(report.other_report) and not is_nil(report.other_report) ->
        ~H"""
        <div class="flex flex-col justify-around align-middle h-full w-full">
          <div class="flex flex-row justify-center text-center card-title">
            <% translate(@locale, "create_report.details") %>
          </div>
          <div class="flex flex-row align-middle p-3 w-11/12 ml-[10px] bg-accent rounded-xl">
            <div class="flex flex-row h-3/3 w-2/12">
              <img class="mr-[10px]" src="/images/report_icons/comment.svg" />
            </div>
            <div class="w-10/12">
              <p class="line-clamp-3"><%= comment %></p>
            </div>
          </div>
          <div class="flex justify-end w-11/12 mb-[10px]"><%= formatted_date %></div>
        </div>
        """
    end
  end
end
