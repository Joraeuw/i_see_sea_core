defmodule ISeeSeaWeb.ProfileComponents do
  @moduledoc false
  alias ISeeSea.DB.Models.OtherReport
  alias ISeeSea.DB.Models.PollutionReport
  alias ISeeSea.DB.Models.MeteorologicalReport
  alias ISeeSea.DB.Models.AtypicalActivityReport
  alias ISeeSea.DB.Models.JellyfishReport
  alias ISeeSea.DB.Models.BaseReport

  use Phoenix.Component

  attr :view, :string, required: true
  attr :username, :string, required: true
  attr :email, :string, required: true
  attr :user_report_summary, :list, required: true
  attr :user_reports, :list, required: true
  attr :is_edit_mode, :boolean, default: false

  attr :current_page, :integer, required: true
  attr :total_pages, :integer, required: true

  def index(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-start">
      <div class="relative flex flex-row items-center justify-center bg-secondary rounded-md p-2 m-2 mb-6">
        <div class="avatar placeholder m-2">
          <div class="bg-neutral text-neutral-content w-24 rounded-full">
            <span class="text-3xl"><%= String.upcase(String.first(@username)) %></span>
          </div>
        </div>
        <div class="flex flex-col gap-3 ml-2">
          <input
            type="text"
            username="username"
            value={@username}
            class="input input-bordered w-full max-w-xs"
            disabled={not @is_edit_mode}
          />
          <input
            type="text"
            username="email"
            value={@email}
            class="input input-bordered w-full max-w-xs"
            disabled={not @is_edit_mode}
          />
        </div>

        <div class="flex flex-col">
          <%!-- Edit profile left for later when user profile pic uploading is setup --%>
          <div class="hidden">
            <button :if={not @is_edit_mode} class="btn" phx-click="edit_profile">Edit profile</button>
            <div class="join">
              <button
                :if={@view === "my_profile_view" && @is_edit_mode}
                class="btn btn-success"
                phx-click="toggle_profile_view"
                phx-value-view="my_profile_view"
              >
                Save
              </button>

              <button
                :if={@view === "my_profile_view" && @is_edit_mode}
                class="btn btn-error"
                phx-click="toggle_profile_view"
                phx-value-view="my_profile_view"
              >
                Cancel
              </button>
            </div>
          </div>
          <button
            :if={@view === "my_reports_view"}
            class="btn ml-3"
            phx-click="toggle_profile_view"
            phx-value-view="my_profile_view"
          >
            My Profile
          </button>

          <button
            :if={@view === "my_profile_view"}
            class="btn ml-3"
            phx-click="toggle_profile_view"
            phx-value-view="my_reports_view"
            disabled={@is_edit_mode}
          >
            My Reports
          </button>
        </div>
      </div>

      <.my_report_summary_view
        :if={@view === "my_profile_view"}
        user_report_summary={@user_report_summary}
      />
      <.my_report_view :if={@view === "my_reports_view"} user_reports={@user_reports} />
    </div>
    """
  end

  attr :user_report_summary, :list, required: true

  def my_report_summary_view(assigns) do
    ~H"""
    <div class="flex flex-wrap justify-center gap-2 py-6 md:px-6 bg-gray-50 rounded-md shadow-md mb-6">
      <div
        :for={{type, image, count} <- @user_report_summary}
        class="card card-compact bg-base-100 w-96 shadow-xl"
      >
        <figure>
          <img src={image} alt="Shoes" />
        </figure>
        <div class="card-body shadow-md rounded-md">
          <h2 class="card-title"><%= type %></h2>
          <p>Count of your reports: <%= count %></p>
          <div class="card-actions justify-end">
            <button class="btn btn-primary">See Reports</button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :user_reports, :list, required: true

  def my_report_view(assigns) do
    ~H"""
    <div class="flex flex-wrap justify-center gap-10 py-6 md:px-6 bg-gray-50 rounded-md shadow-md mb-6 w-full h-full">
      <%= for %BaseReport{name: name, comment: comment, pictures: pictures} = report <- @user_reports do %>
        <!-- Polaroid card container with perspective for 3D effect -->
        <.live_component
          module={ISeeSeaWeb.ReportCardLiveComponent}
          id={report.id}
          name={name}
          comment={comment}
          pictures={pictures}
        />
      <% end %>
    </div>
    """
  end

  attr :report, :map, required: true

  defp back_of_report(
         %{
           report: %BaseReport{
             jellyfish_report: %JellyfishReport{quantity: quantity, species: species}
           }
         } = assigns
       ) do
    ~H"""
    """
  end

  defp back_of_report(
         %{report: %BaseReport{atypical_activity_report: %AtypicalActivityReport{}}} = assigns
       ) do
    ~H"""
    """
  end

  defp back_of_report(
         %{report: %BaseReport{meteorological_report: %MeteorologicalReport{}}} = assigns
       ) do
    ~H"""
    """
  end

  defp back_of_report(%{report: %BaseReport{pollution_report: %PollutionReport{}}} = assigns) do
    ~H"""
    """
  end

  defp back_of_report(%{report: %BaseReport{other_report: %OtherReport{}}} = assigns) do
    ~H"""
    """
  end
end
