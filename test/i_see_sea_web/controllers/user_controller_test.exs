defmodule ISeeSeaWeb.UserControllerTest do
  @moduledoc false
  alias ISeeSea.DB.Models.User
  alias ISeeSea.Events.UserEmailVerification
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

  describe "verify_email/2" do
    test "successfully verify user email", %{conn: conn} do
      %{id: user_id, verified: false} = insert!(:user, verified: false)
      token = UUID.uuid4()
      UserEmailVerification.start_tracker(user_id, token)

      conn
      |> get(Routes.user_path(conn, :verify_email, token))
      |> response(204)

      assert {:ok, %{verified: true}} = User.get(user_id)
      assert {:error, :not_found} = UserEmailVerification.get_scheduled(token)
    end

    test "fail to verify user email when token is invalid", %{conn: conn} do
      %{id: user_id} = insert!(:user, verified: false)
      token = UUID.uuid4()
      UserEmailVerification.start_tracker(user_id, token)

      response =
        conn
        |> get(Routes.user_path(conn, :verify_email, "invalid_token"))
        |> json_response(404)

      assert %{
               "message" => "The requested action has failed.",
               "reason" => "The resource could not be found."
             } == response

      assert {:ok, %{verified: false}} = User.get(user_id)
    end
  end
end
