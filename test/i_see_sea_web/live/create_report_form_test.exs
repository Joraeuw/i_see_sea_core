defmodule ISeeSeaWeb.Test.CreateReportFormTest do
  alias ISeeSea.Constants
  use ISeeSeaWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias ISeeSea.DB.Models.UserToken
  alias ISeeSea.Repo
  alias ISeeSea.DB.Models.User
  alias ISeeSea.DB.Models.JellyfishReport
  alias ISeeSea.DB.Models.AtypicalActivityReport
  alias ISeeSea.DB.Models.PollutionReport
  alias ISeeSea.DB.Models.OtherReport
  alias ISeeSea.DB.Models.MeteorologicalReport
  alias ISeeSea.DB.Models.PollutionType
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

  test "succesfully create an atypical report", %{user_conn: conn} do
    {:ok, view, _html} = live(conn, Routes.home_path(conn, :home_index))

    params = %{
      name: "new_storm",
      comment: "my comment",
      storm_type: "thunderstorm"
    }

    view
    |> element("#atypical_activity_create_report_button")
    |> render_click()

    view
    |> element("#select-location-button")
    |> render_click()

    view
    |> element("#select-location-button")
    |> render_hook("location_selected", %{"lat" => 43, "lng" => 43})

    view
    |> form("#create-report-form",
      report_params: params
    )
    |> render_submit()

    # maybe check other event
    assert_push_event(view, "report_created", %{})

    assert {:ok,
            [
              %AtypicalActivityReport{
                storm_type_id: "thunderstorm",
                base_report: %BaseReport{
                  name: "new_storm",
                  comment: "my comment",
                  latitude: 43.0,
                  longitude: 43.0
                }
              }
            ]} =
             AtypicalActivityReport.all()
  end

  test "succesfully create a meteorological report", %{user_conn: conn} do
    {:ok, view, _html} = live(conn, Routes.home_path(conn, :home_index))

    params = %{
      name: "new_meteor",
      comment: "my comment",
      fog_type: "very_thick",
      wind_type: "hurricane",
      sea_swell_type: "strong"
    }

    view
    |> element("#meteorological_create_report_button")
    |> render_click()

    view
    |> element("#select-location-button")
    |> render_click()

    view
    |> element("#select-location-button")
    |> render_hook("location_selected", %{"lat" => 44, "lng" => 44})

    view
    |> form("#create-report-form",
      report_params: params
    )
    |> render_submit()

    # maybe check other event
    assert_push_event(view, "report_created", %{})

    assert {:ok,
            [
              %MeteorologicalReport{
                fog_type_id: "very_thick",
                wind_type_id: "hurricane",
                sea_swell_type_id: "strong",
                base_report: %BaseReport{
                  name: "new_meteor",
                  comment: "my comment",
                  latitude: 44.0,
                  longitude: 44.0
                }
              }
            ]} =
             MeteorologicalReport.all()
  end

  test "succesfully create an other report", %{user_conn: conn} do
    {:ok, view, _html} = live(conn, Routes.home_path(conn, :home_index))

    params = %{
      name: "new_other",
      comment: "my comment"
    }

    view
    |> element("#other_create_report_button")
    |> render_click()

    view
    |> element("#select-location-button")
    |> render_click()

    view
    |> element("#select-location-button")
    |> render_hook("location_selected", %{"lat" => 45, "lng" => 45})

    view
    |> form("#create-report-form",
      report_params: params
    )
    |> render_submit()

    # maybe check other event
    assert_push_event(view, "report_created", %{})

    assert {:ok,
            [
              %OtherReport{
                base_report: %BaseReport{
                  name: "new_other",
                  comment: "my comment",
                  latitude: 45.0,
                  longitude: 45.0
                }
              }
            ]} =
             OtherReport.all()
  end

  test "succesfully create a pollution report", %{user_conn: conn} do
    {:ok, view, _html} = live(conn, Routes.home_path(conn, :home_index))

    params = %{
      pollution_type_oil: true,
      name: "new_pollution",
      comment: "my comment"
    }

    view
    |> element("#pollution_create_report_button")
    |> render_click()

    view
    |> element("#select-location-button")
    |> render_click()

    view
    |> element("#select-location-button")
    |> render_hook("location_selected", %{"lat" => 46, "lng" => 46})

    view
    |> form("#create-report-form",
      report_params: params
    )
    |> render_submit()

    # maybe check other event
    assert_push_event(view, "report_created", %{})

    assert {:ok,
            [
              %PollutionReport{
                pollution_types: [%PollutionType{name: "oil"}],
                base_report: %BaseReport{
                  name: "new_pollution",
                  comment: "my comment",
                  latitude: 46.0,
                  longitude: 46.0
                }
              }
            ]} =
             PollutionReport.all()
  end

  test "not selected location when creating an atypical report", %{user_conn: conn} do
    {:ok, view, _html} = live(conn, Routes.home_path(conn, :home_index))

    params = %{
      name: "new_storm",
      comment: "my comment",
      storm_type: "thunderstorm"
    }

    view
    |> element("#atypical_activity_create_report_button")
    |> render_click()

    view
    |> element("#select-location-button")
    |> render_click()

    view
    |> form("#create-report-form",
      report_params: params
    )
    |> render_submit()

    assert render(view) =~ "You have not selected a location."
  end

  test "not selected location when creating a jellyfish report", %{user_conn: conn} do
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
    |> form("#create-report-form",
      report_params: params
    )
    |> render_submit()

    assert render(view) =~ "You have not selected a location."
  end

  test "not selected location when creating a meteorological report", %{user_conn: conn} do
    {:ok, view, _html} = live(conn, Routes.home_path(conn, :home_index))

    params = %{
      name: "new_meteor",
      comment: "my comment",
      fog_type: "very_thick",
      wind_type: "hurricane",
      sea_swell_type: "strong"
    }

    view
    |> element("#meteorological_create_report_button")
    |> render_click()

    view
    |> element("#select-location-button")
    |> render_click()

    view
    |> form("#create-report-form",
      report_params: params
    )
    |> render_submit()

    assert render(view) =~ "You have not selected a location."
  end

  test "not selected location when creating a pollution report", %{user_conn: conn} do
    {:ok, view, _html} = live(conn, Routes.home_path(conn, :home_index))

    params = %{
      pollution_type_oil: true,
      name: "new_pollution",
      comment: "my comment"
    }

    view
    |> element("#pollution_create_report_button")
    |> render_click()

    view
    |> element("#select-location-button")
    |> render_click()

    view
    |> form("#create-report-form",
      report_params: params
    )
    |> render_submit()

    assert render(view) =~ "You have not selected a location."
  end

  test "not selected location when creating a other report", %{user_conn: conn} do
    {:ok, view, _html} = live(conn, Routes.home_path(conn, :home_index))

    params = %{
      name: "new_other",
      comment: "my comment"
    }

    view
    |> element("#other_create_report_button")
    |> render_click()

    view
    |> element("#select-location-button")
    |> render_click()

    view
    |> form("#create-report-form",
      report_params: params
    )
    |> render_submit()

    assert render(view) =~ "You have not selected a location."
  end

  test "reports in my reports view equal your reports", %{user_conn: conn} do
    # Navigate to the profile view
    {:ok, view, _html} = live(conn, Routes.profile_path(conn, :profile_index))

    # Click the "My Reports" button to load reports view
    view
    |> element("#my_reports_button")
    |> render_click()

    # Re-render the view and parse the user reports from the DOM
    html = render(view)

    # Now count how many report components are rendered in the view
    report_count =
      html
      # Adjust the class or identifier
      |> Floki.find("#my_reports_container #report-card")
      |> length()

    # You can assert that the number of reports rendered is as expected
    assert report_count == 0
  end

  test "reports in my reports view equal your reports after u made a report", %{
    user_conn: conn,
    user: user
  } do
    insert!(:jellyfish_report, base_report: build(:base_report, report_date: now(hours: -2)))
    {:ok, view, _html} = live(conn, Routes.profile_path(conn, :profile_index))

    view
    |> element("#my_reports_button")
    |> render_click()

    html = render(view)

    report_count =
      html
      |> Floki.find("#my_reports_container #report-card")
      |> length()

    assert report_count == 1
  end

  # test "reports in my reports view equal your reports after u made a report", %{conn: conn, user: user} do

  # insert!(:jellyfish_report, base_report: build(:base_report,user: user ,report_date: now(hours: -2)))
  #  {:ok, view, _html} = live(conn, Routes.profile_path(conn, :profile_index))

  # view
  # |> element("#my_reports_button")
  # |> render_click()

  # html = render(view)

  # report_count =
  #   html
  #   |> Floki.find("#my_reports_container #report-card")
  #  |> length()

  # assert report_count == 1
  # end
  test "making reports as a non loged in user for jellyfish", %{conn: conn, user: user} do
    {:ok, view, _html} = live(conn, Routes.home_path(conn, :home_index))

    view
    |> element("#jellyfish_create_report_button")
    |> render_click()

    assert_redirect(view, Routes.login_path(conn, :index))
  end

  test "making reports as a non loged in user for meteorological", %{conn: conn, user: user} do
    {:ok, view, _html} = live(conn, Routes.home_path(conn, :home_index))

    view
    |> element("#meteorological_create_report_button")
    |> render_click()

    assert_redirect(view, Routes.login_path(conn, :index))
  end

  test "making reports as a non loged in user for atypical", %{conn: conn, user: user} do
    {:ok, view, _html} = live(conn, Routes.home_path(conn, :home_index))

    view
    |> element("#atypical_activity_create_report_button")
    |> render_click()

    assert_redirect(view, Routes.login_path(conn, :index))
  end

  test "making reports as a non loged in user for pollution", %{conn: conn, user: user} do
    {:ok, view, _html} = live(conn, Routes.home_path(conn, :home_index))

    view
    |> element("#pollution_create_report_button")
    |> render_click()

    assert_redirect(view, Routes.login_path(conn, :index))
  end

  test "making reports as a non loged in user for other", %{conn: conn, user: user} do
    {:ok, view, _html} = live(conn, Routes.home_path(conn, :home_index))

    view
    |> element("#other_create_report_button")
    |> render_click()

    assert_redirect(view, Routes.login_path(conn, :index))
  end

  test "trying to go to profile page as a non loged in user", %{conn: conn, user: user} do
    {:ok, view, _html} = live(conn, Routes.home_path(conn, :home_index))

    view
    |> element("[navigate='/profile']")
    |> render_click()

    assert_redirect(view, Routes.login_path(conn, :index))
  end

  test "trying to register", %{conn: conn} do
    params = %{
      "first_name" => "John",
      "last_name" => "Doe",
      "username" => "johndoe123",
      "email" => "johndoe@example.com",
      "password" => "A123456"
    }

    {:ok, view, _html} = live(conn, Routes.register_path(conn, :index))

    view
    |> form("#registration_form", user: params)
    |> render_submit()

    assert Repo.get_by(User, email: params["email"])
  end

  test "successful login", %{conn: conn} do
    user = insert!(:user, email: "johndoe@example.com", password: Bcrypt.hash_pwd_salt("A123456"))

    {:ok, view, _html} = live(conn, Routes.login_path(conn, :index))

    conn =
      post(conn, Routes.session_path(conn, :login), %{
        "user" => %{
          "email" => user.email,
          "password" => "A123456"
        }
      })

    IO.inspect(get_flash(conn))

    assert redirected_to(conn) == Routes.home_path(conn, :home_index)
  end

  test "trying to access login page when already logged in", %{user_conn: conn, user: user} do
    conn = get(conn, Routes.session_path(conn, :login))

    assert redirected_to(conn) == Routes.home_path(conn, :home_index)
  end

  test "trying to access register page when already logged in", %{user_conn: conn, user: user} do
    conn = get(conn, Routes.register_path(conn, :index))

    assert redirected_to(conn) == Routes.home_path(conn, :home_index)
  end

  defp now(shift \\ []) do
    DateTime.utc_now()
    |> Timex.shift(shift)
    |> DateTime.truncate(:second)
  end

  defp now_utc(shift \\ []) do
    DateTime.utc_now()
    |> Timex.shift(shift)
    |> DateTime.truncate(:second)
  end
end
