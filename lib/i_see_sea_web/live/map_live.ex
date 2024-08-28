defmodule ISeeSeaWeb.MapLive do
  use ISeeSeaWeb, :live_view

  alias ISeeSeaWeb.Params.Filter
  alias ISeeSea.DB.Models.BaseReport

  @impl true
  def render(assigns) do
    ~L"""
    <div>
      <div id="map" phx-hook="LeafletMap" data-reports={Jason.encode!(@reports)} style="height: 650px;"></div>
      <img src={~p"/images/marker-icons/jellyfish.png"} alt="Logo">
      <div id="button" bg="">
        <img src/>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: ISeeSeaWeb.Endpoint.subscribe("reports:updates")

    IO.inspect(session)
    filters =
      Filter.parse_data_ranges([
        %{"field" => "from_date", "value" => DateTime.utc_now() |> Timex.shift(days: -1)},
        %{"field" => "to_date", "value" => DateTime.utc_now()}
      ])

    with {:ok, reports, _} <-
           BaseReport.get_with_filter(%{filters: filters}, %{page_size: 9999, page: 1}),
         parsed_reports <- Focus.view(reports, %Lens{view: Lens.expanded()}) do
          IO.inspect(parsed_reports |> hd())
      {:ok, assign(socket, :reports, parsed_reports)}
    end
  end

  def handle_info(%{event: "add_marker", payload: marker}, socket) do
    {:noreply, push_event(socket, "add_marker", marker)}
  end

  def handle_info(%{event: "update_marker", payload: marker}, socket) do
    {:noreply, push_event(socket, "update_marker", marker)}
  end

  def handle_info(%{event: "delete_marker", payload: marker_id}, socket) do
    {:noreply, push_event(socket, "delete_marker", %{id: marker_id})}
  end
end
