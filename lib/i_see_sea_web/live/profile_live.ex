defmodule ISeeSeaWeb.ProfileLive do
  use ISeeSeaWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div class="conteiner">
      <div class="profile_info">

      <div class="prolife_img">
        <img  id="profile_picture" src="https://play-lh.googleusercontent.com/LeX880ebGwSM8Ai_zukSE83vLsyUEUePcPVsMJr2p8H3TUYwNg-2J_dVMdaVhfv1cHg"/>
      </div>
        <div class="information">
        <div class="profile_name">
          <p>Name: </p>
        </div>
        <div class="profile_email">
          <p>Email: </p>
        </div>
      </div>
       <div class="edit">
        <button class="edit_button">Edit profile</button>
       </div>
       <div class="my_reports">
         <button class="my_reports_button">My Reports</button>
       </div>
    </div>


      <div class="Reports">
        <div class="type_reports">
          <div class="square-dark-m"></div>
          <p>Meduse</p>
          <img src="js/457024426_1469318094460169_2119878259453164702_n-transformed.png" alt="nz"/>
          <p>0</p>
        </div>
        <div class="type_reports">
          <p>Storm</p>
          <img src="js/file.png" alt="nz"/>
          <p>0</p>
        </div>
        <div class="type_reports">
          <p>Weather</p>
          <img src="js/456687995_849946990204883_6562033642958707367_n-transformed.png" alt="nz"/>
          <p>0</p>
        </div>
        <div class="type_reports">
          <p>Pollution</p>
          <img src="js/file (1).png" alt="nz"/>
          <p>0</p>
        </div>
        <div class="type_reports">
          <p>Other</p>
          <img src="js/file (2).png" alt="nz"/>
          <p>0</p>
        </div>
        <div class="last_report"></div>

      </div>
      </div>
    """
  end
end
