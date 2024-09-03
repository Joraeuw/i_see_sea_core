defmodule ISeeSeaWeb.HomeLive do
  use ISeeSeaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""


<div class="Page">
<div class="Conteiner">
  <div class="Reports">
    <div class="square-dark-m"></div>
    <div class="square-light-bottm-m"></div>
    <div class="square-light-bottm-m1"></div>
    <div class="square-light-bottm-m2"></div>
    <div class="square-dark-m1"></div>
    <div class="square-dark-m2"></div>
    <button class="ReportButton" id="jelly">
      <img id="jelly_img" src="/images/Assetss/medusa1.jpeg"/>
    </button>
    <button class="ReportButton" id="storm">
    <img src="/images/Assetss/weather.jpeg"/></button>
    <button class="ReportButton" id="umbrella">
      <img src="/images/Assetss/umbrella.jpeg"/>
    </button>
    <button class="ReportButton" id="pollution">
    <img src="/images/Assetss/pollution1.jpeg"/>
    </button>
    <button class="ReportButton" id="oil">
    <img src="/images/Assetss/oil.jpeg"/></button>
  </div>

  <div class="MapInfo">
    <div class="Map">
      <%= live_render(@socket, ISeeSeaWeb.MapLive, id: "map-live") %>
    </div>

    <div class="Info">

    </div>
  </div>
  <div class="Right-info">

    <button class="filter">
    Filters
    </button>
    <div class="All_reports">
    <div class="text-overlay">Report</div>
    <img src="/images/Assetss/proba1.jpg"/>
</div>

<div class="users">
    <div class="text-overlay">User</div>
    <img src="/images/Assetss/proba1.jpg"/>
</div>



  </div>
</div>
</div>

    """
  end
end
