defmodule ISeeSeaWeb.Live.JellyfishReportLiveTest do
  use ISeeSeaWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  alias ISeeSea.Repo
  alias ISeeSea.DB.Models.{User, JellyfishSpecies, JellyfishReport, BaseReport}

  setup %{conn: conn} do
    user = insert!(:user, first_name: "gosho")

    {:ok, %{
      conn: conn,
      user: user
    }}
  end

  test "displays correct count of active jellyfish reports", %{conn: conn} do
    # Insert reports into the database
    insert!(:jellyfish_report, base_report: build(:base_report, report_date: now_utc(hours: -2), deleted: false))
    insert!(:jellyfish_report, base_report: build(:base_report, report_date: now_utc(), deleted: false))
    insert!(:jellyfish_report, base_report: build(:base_report, report_date: now_utc(days: -2), deleted: false))
    insert!(:jellyfish_report, base_report: build(:base_report, report_date: now_utc(days: -1), deleted: true))  # Deleted report

    # Navigate to the LiveView page
    {:ok, view, _html} = live(conn, Routes.home_path(conn, :home_index))

    # Assert that the page displays "3 active jellyfish reports" as expected
    assert render(view) =~ "3 active jellyfish reports"
  end

  defp now_utc(shift \\ []) do
    NaiveDateTime.utc_now()
    |> Timex.shift(shift)
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.truncate(:second)  # Remove microseconds
  end
end
