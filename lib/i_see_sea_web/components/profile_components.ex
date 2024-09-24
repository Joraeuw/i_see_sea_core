defmodule ISeeSeaWeb.ProfileComponents do
  @moduledoc false
  alias ISeeSea.DB.Models.BaseReport
  alias ISeeSeaWeb.CommonComponents

  use Phoenix.Component

  attr :view, :string, required: true
  attr :username, :string, required: true
  attr :email, :string, required: true
  attr :user_report_summary, :list, required: true
  attr :user_reports, :list, required: true
  attr :is_edit_mode, :boolean, default: false

  attr :supports_touch, :boolean, required: true
  attr :filters, :map, required: true
  attr :filter_menu_is_open, :boolean, required: true
  attr :stats_panel_is_open, :boolean, required: true

  attr :pagination, :map, required: true

  def index(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-start">
      <div class="relative flex flex-col md:flex-row items-center justify-center bg-secondary rounded-md p-2 m-2 mb-6">
        <div class="avatar placeholder m-2 md:mr-10">
          <div class="bg-neutral text-neutral-content w-20 h-20 md:w-24 md:h-24 rounded-full flex items-center justify-center">
            <span class="text-3xl"><%= String.upcase(String.first(@username)) %></span>
          </div>
        </div>
        <!-- User Info -->
        <div class="flex flex-col gap-3 ml-2 w-full md:w-1/2 lg:w-1/3 md:mr-8">
          <input
            type="text"
            name="username"
            value={@username}
            class="input input-bordered w-full"
            disabled={not @is_edit_mode}
          />
          <input
            type="text"
            name="email"
            value={@email}
            class="input input-bordered w-full"
            disabled={not @is_edit_mode}
          />
        </div>
        <!-- Action Buttons -->
        <div class="flex flex-col gap-3 mt-4 md:mt-0">
          <!-- Edit profile buttons hidden until needed -->
          <div class="hidden">
            <button :if={not @is_edit_mode} class="btn" phx-click="edit_profile">Edit profile</button>
            <div class="flex gap-2">
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
          <!-- Profile and Reports navigation -->
          <button
            :if={@view === "my_reports_view"}
            class="btn ml-0 md:ml-3"
            phx-click="toggle_profile_view"
            phx-value-view="my_profile_view"
          >
            My Profile
          </button>

          <CommonComponents.filter_button
            :if={@view === "my_reports_view"}
            class="btn ml-0 md:ml-3"
            filters={@filters}
          />

          <button
            :if={@view === "my_profile_view"}
            class="btn ml-0 md:ml-3"
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

      <CommonComponents.pagination :if={@view === "my_reports_view"} pagination={@pagination} />
      <.my_report_view :if={@view === "my_reports_view"} user_reports={@user_reports} />
      <CommonComponents.pagination :if={@view === "my_reports_view"} pagination={@pagination} />
    </div>
    """
  end

  attr :user_report_summary, :list, required: true

  def my_report_summary_view(assigns) do
    ~H"""
    <div class="flex flex-wrap justify-center gap-5 py-6 md:px-6  w-[calc(100vw-5em)] bg-gray-50 rounded-md shadow-md mb-6">
      <div
        :for={{type, image, count} <- @user_report_summary}
        class="card card-compact bg-base-100 w-72 shadow-xl"
      >
        <figure class="h-80">
          <img class="bg-cover" src={image} alt="Shoes" />
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
    <div class="flex flex-wrap justify-center gap-10 py-6 md:px-6 bg-gray-50 rounded-md shadow-md  mt-3 mb-6 w-[calc(100vw-5em)] mx-10 h-auto">
      <%= for %BaseReport{name: name, comment: comment, pictures: pictures} = report <- @user_reports do %>
        <!-- Polaroid card container with perspective for 3D effect -->
        <.live_component
          module={ISeeSeaWeb.ReportCardLiveComponent}
          id={report.id}
          name={name}
          comment={comment}
          pictures={pictures}
          report={report}
          show_extra_button={false}
        />
      <% end %>
    </div>
    """
  end
end
