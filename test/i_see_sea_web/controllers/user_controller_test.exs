defmodule ISeeSeaWeb.UserControllerTest do
  @moduledoc false
  use ISeeSeaWeb.ConnCase, async: true

  describe "list_reports/2" do
    test "successfully retrieve report data", %{conn_user: conn, user: user} do
      insert!(:pollution_report)
      insert!(:jellyfish_report)
      insert!(:atypical_activity_report)

      insert!(:pollution_report, base_report: build(:base_report, user: user))
      insert!(:jellyfish_report, base_report: build(:base_report, user: user))
      insert!(:meteorological_report, base_report: build(:base_report, user: user))
      insert!(:atypical_activity_report, base_report: build(:base_report, user: user))

      response =
        conn
        |> get(Routes.user_path(conn, :list_reports, "all"))
        |> json_response(200)

      assert %{"pagination" => %{"page" => 1, "page_size" => 10, "total_count" => 4}} = response
    end

    test "fail to retrieve report data when unauthenticated", %{conn: conn} do
      response =
        conn
        |> get(Routes.user_path(conn, :list_reports, "all"))
        |> json_response(401)

      assert %{
               "message" => "The requested action has failed.",
               "reason" => "Authentication credentials were missing or incorrect."
             } == response
    end
  end
end
