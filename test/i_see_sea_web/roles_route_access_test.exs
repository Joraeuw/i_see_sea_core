defmodule ISeeSeaWeb.RolesRouteAccessTest do
  @moduledoc """
  Tests that check each and every route for correct access rights
  """

  use ISeeSeaWeb.ConnCase, async: true

  alias ISeeSea.Constants.ReportType

  describe "users:list_reports" do
    for {role, status} <- [
          {"end_user", 200},
          {"admin", 200}
        ] do
      test role, test_setup_params do
        conn = Map.get(test_setup_params, String.to_atom("conn_#{unquote(role)}"))

        assert conn
               |> get(Routes.user_path(conn, :list_reports, "all"))
               |> json_response(unquote(status))
      end
    end
  end

  describe "sessions:register" do
    for {role, status} <- [
          {"end_user", 200},
          {"admin", 200}
        ] do
      test role, test_setup_params do
        conn = Map.get(test_setup_params, String.to_atom("conn_#{unquote(role)}"))

        params = %{
          first_name: "Sam",
          last_name: "Blue",
          email: "email@gmail.com",
          password: "A123456",
          username: "Dobby"
        }

        assert conn
               |> post(Routes.session_path(conn, :register), params)
               |> json_response(unquote(status))
      end
    end
  end

  describe "sessions:login" do
    for {role, status} <- [
          {"end_user", 200},
          {"admin", 200}
        ] do
      test role, test_setup_params do
        user = Map.get(test_setup_params, String.to_atom(unquote(role)))
        conn = Map.get(test_setup_params, String.to_atom("conn_#{unquote(role)}"))

        params = %{
          email: user.email,
          password: "A123456"
        }

        assert conn
               |> post(Routes.session_path(conn, :login), params)
               |> json_response(unquote(status))
      end
    end
  end

  describe "sessions:refresh" do
    for {role, status} <- [
          {"end_user", 200},
          {"admin", 200}
        ] do
      test role, test_setup_params do
        conn = Map.get(test_setup_params, String.to_atom("conn_#{unquote(role)}"))

        assert conn
               |> get(Routes.session_path(conn, :refresh))
               |> json_response(unquote(status))
      end
    end
  end

  describe "reports:create" do
    for {role, status} <- [
          {"end_user", 200},
          {"admin", 200}
        ] do
      test role, test_setup_params do
        conn = Map.get(test_setup_params, String.to_atom("conn_#{unquote(role)}"))

        params = %{
          name: Faker.Lorem.sentence(3..4),
          longitude: Faker.Address.longitude(),
          latitude: Faker.Address.latitude(),
          quantity: 50
        }

        assert conn
               |> post(Routes.report_path(conn, :create_report, ReportType.jellyfish()), params)
               |> json_response(unquote(status))
      end
    end
  end

  describe "reports:index" do
    for {role, status} <- [
          {"end_user", 200},
          {"admin", 200}
        ] do
      test role, test_setup_params do
        conn = Map.get(test_setup_params, String.to_atom("conn_#{unquote(role)}"))

        assert conn
               |> get(Routes.report_path(conn, :index, "all"))
               |> json_response(unquote(status))
      end
    end
  end
end
