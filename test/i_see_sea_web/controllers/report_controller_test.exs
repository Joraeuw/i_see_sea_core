defmodule ISeeSeaWeb.ReportControllerTest do
  use ISeeSeaWeb.ConnCase, async: true

  alias ISeeSea.DB.Models.PollutionReport
  alias ISeeSea.DB.Models.PollutionReportPollutionType
  alias ISeeSea.DB.Models.PollutionType
  alias ISeeSea.DB.Models.JellyfishReport

  alias ISeeSea.Constants.ReportType

  describe "create_report/2" do
    test "jellyfish report created successfully", %{conn_user: conn} do
      params = %{
        name: Faker.Lorem.sentence(3..4),
        longitude: Faker.Address.longitude(),
        latitude: Faker.Address.latitude(),
        quantity: 50
      }

      response =
        conn
        |> post(Routes.report_path(conn, :create_report, ReportType.jellyfish()), params)
        |> json_response(200)

      assert %{
               "report_id" => id,
               "latitude" => _,
               "longitude" => _,
               "name" => _,
               "quantity" => 50,
               "report_date" => _,
               "report_type" => "jellyfish",
               "species" => ""
             } =
               response

      assert {:ok, %JellyfishReport{}} = JellyfishReport.get_by(%{report_id: id})
    end

    test "pollution report created successfully", %{conn_user: conn} do
      insert!(:pollution_type, name: "oil")
      insert!(:pollution_type, name: "plastic")

      params = %{
        name: Faker.Lorem.sentence(3..4),
        longitude: Faker.Address.longitude(),
        latitude: Faker.Address.latitude(),
        pollution_types: ["oil", "plastic"]
      }

      response =
        conn
        |> post(Routes.report_path(conn, :create_report, ReportType.pollution()), params)
        |> json_response(200)

      assert %{
               "report_id" => id,
               "latitude" => _,
               "longitude" => _,
               "name" => _,
               "report_date" => _,
               "report_type" => "pollution",
               "pollution_types" => ["oil", "plastic"]
             } = response

      assert {:ok, %PollutionReport{}} = PollutionReport.get_by(%{report_id: id})
      assert 2 == PollutionReportPollutionType.all() |> elem(1) |> length()
    end

    test "pollution type from another report is recognized", %{conn_user: conn, user: user} do
      p_type = insert!(:pollution_type, name: "oil")

      base = insert!(:base_report, user: user)
      insert!(:pollution_report, base_report: base)

      insert!(:pollution_report_pollution_type,
        pollution_report_id: base.id,
        pollution_type_id: p_type.name
      )

      params = %{
        name: Faker.Lorem.sentence(3..4),
        longitude: Faker.Address.longitude(),
        latitude: Faker.Address.latitude(),
        pollution_types: ["oil"]
      }

      response =
        conn
        |> post(Routes.report_path(conn, :create_report, ReportType.pollution()), params)
        |> json_response(200)

      assert %{
               "report_id" => id,
               "latitude" => _,
               "longitude" => _,
               "name" => _,
               "report_date" => _,
               "report_type" => "pollution",
               "pollution_types" => ["oil"]
             } = response

      assert {:ok, %PollutionReport{}} = PollutionReport.get_by(%{report_id: id})
      assert 1 == PollutionType.all() |> elem(1) |> length()
      assert 2 == PollutionReportPollutionType.all() |> elem(1) |> length()
    end

    test "pollution type isn't recognized", %{conn_user: conn} do
      params = %{
        name: Faker.Lorem.sentence(3..4),
        longitude: Faker.Address.longitude(),
        latitude: Faker.Address.latitude(),
        pollution_types: ["oil", "plastic"]
      }

      response =
        conn
        |> post(Routes.report_path(conn, :create_report, ReportType.pollution()), params)
        |> json_response(422)

      assert %{
               "message" => "The requested action has failed.",
               "reason" => "Something went wrong."
             } == response
    end

    test "fail to create report due to missing base report parameters", %{conn_user: conn} do
      params = %{
        name: Faker.Lorem.sentence(3..4),
        quantity: 50
      }

      response =
        conn
        |> post(Routes.report_path(conn, :create_report, ReportType.jellyfish()), params)
        |> json_response(422)

      assert %{
               "errors" => [
                 %{"latitude" => "can't be blank"},
                 %{"longitude" => "can't be blank"}
               ],
               "message" => "The requested action has failed.",
               "reason" => "Latitude can't be blank, longitude can't be blank."
             } == response
    end

    test "fail to create report due to missing report specific parameters", %{conn_user: conn} do
      params = %{
        name: Faker.Lorem.sentence(3..4),
        longitude: Faker.Address.longitude(),
        latitude: Faker.Address.latitude()
      }

      response =
        conn
        |> post(Routes.report_path(conn, :create_report, ReportType.jellyfish()), params)
        |> json_response(422)

      assert %{
               "errors" => [
                 %{"quantity" => "can't be blank"}
               ],
               "message" => "The requested action has failed.",
               "reason" => "Quantity can't be blank."
             } == response
    end
  end
end
