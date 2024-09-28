defmodule ISeeSeaWeb.Test.CreateReportFormTest do
  alias ISeeSea.Constants
  use ISeeSeaWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias ISeeSea.DB.Models.UserToken
  alias ISeeSea.Repo
  alias ISeeSea.DB.Models.User
  alias ISeeSea.DB.Models.JellyfishReport
  alias ISeeSea.DB.Models.BaseReport

  require ISeeSea.Constants.ReportType, as: ReportType

  alias Plug.Conn

  setup %{conn: conn} do
    user = insert!(:user, first_name: "gosho")
    %UserToken{token: valid_token} = insert!(:user_token, user: user)

    user_conn =
      conn
      |> Phoenix.ConnTest.init_test_session(%{})
      |> Conn.put_session(:user_token, valid_token)
      |> Conn.put_session(:live_socket_id, "i_see_sea:sessions:#{Base.url_encode64(valid_token)}")

    {:ok,
     %{
       conn: conn,
       user_conn: user_conn,
       user: user
     }}
  end

  # test "displays correct count of active jellyfish reports", %{conn: conn} do
  #   # Insert reports into the database
  #   insert!(:jellyfish_report,
  #     base_report: build(:base_report, report_date: now_utc(hours: -2), deleted: false)
  #   )

  #   insert!(:jellyfish_report,
  #     base_report: build(:base_report, report_date: now_utc(), deleted: false)
  #   )

  #   insert!(:jellyfish_report,
  #     base_report: build(:base_report, report_date: now_utc(days: -2), deleted: false)
  #   )

  #   # Deleted report
  #   insert!(:jellyfish_report,
  #     base_report: build(:base_report, report_date: now_utc(days: -1), deleted: true)
  #   )

  #   # Navigate to the LiveView page
  #   {:ok, view, _html} = live(conn, Routes.home_path(conn, :home_index))

  #   # Assert that the page displays "3 active jellyfish reports" as expected
  # end

  test "successfully create a jellyfish report", %{user_conn: conn} do
    {:ok, view, _html} = live(conn, Routes.home_path(conn, :home_index))

    params = %{
      name: "new_jelly",
      comment: "my comment",
      quantity: Constants.JellyfishQuantityRange.from_11_to_99(),
      species: "dont_know"
    }

    view
    |> element("#jellyfish_create_report_button")
    |> render_click()

    view
    |> element("#select-location-button")
    |> render_click()

    view
    |> element("#select-location-button")
    |> render_hook("location_selected", %{"lat" => 42, "lng" => 42})

    view
    |> form("#create-report-form",
      report_params: params
    )
    |> render_submit()

    # maybe check other event
    assert_push_event(view, "report_created", %{})

    assert {:ok,
            [
              %JellyfishReport{
                species_id: "dont_know",
                quantity: "11 to 99",
                base_report: %BaseReport{
                  name: "new_jelly",
                  comment: "my comment",
                  latitude: 42.0,
                  longitude: 42.0
                }
              }
            ]} =
             JellyfishReport.all()
  end

  defp now_utc(shift \\ []) do
    DateTime.utc_now()
    |> Timex.shift(shift)
    |> DateTime.truncate(:second)
  end
end
