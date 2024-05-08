defmodule ISeeSeaWeb.Specs.ReportSchemaTest do
  @moduledoc false
  alias ISeeSea.Constants.ReportType
  use ISeeSeaWeb.ConnCase, async: true
  import OpenApiSpex.TestAssertions

  describe "report schema" do
    test "create jellyfish report", %{conn_user: conn, api_spec: api_spec} do
      params = %{
        name: Faker.Lorem.sentence(3..4),
        longitude: Faker.Address.longitude(),
        latitude: Faker.Address.latitude(),
        quantity: 50
      }

      json =
        conn
        |> post(Routes.report_path(conn, :create_report, ReportType.jellyfish()), params)
        |> json_response(200)

      assert_schema(json, "CreateReportResponse", api_spec)
    end

    test "create pollution report", %{conn_user: conn, api_spec: api_spec} do
      insert!(:pollution_type, name: "oil")
      insert!(:pollution_type, name: "plastic")

      params = %{
        name: Faker.Lorem.sentence(3..4),
        longitude: Faker.Address.longitude(),
        latitude: Faker.Address.latitude(),
        pollution_types: ["oil", "plastic"]
      }

      json =
        conn
        |> post(Routes.report_path(conn, :create_report, ReportType.pollution()), params)
        |> json_response(200)

      assert_schema(json, "CreateReportResponse", api_spec)
    end

    test "create meteorological report", %{conn_user: conn, api_spec: api_spec} do
      insert!(:wind_type, name: "strong")
      insert!(:fog_type, name: "thick")
      insert!(:sea_swell_type, name: "strong")

      params = %{
        name: Faker.Lorem.sentence(3..4),
        longitude: Faker.Address.longitude(),
        latitude: Faker.Address.latitude(),
        fog_type: "thick",
        wind_type: "strong",
        sea_swell_type: "strong"
      }

      json =
        conn
        |> post(Routes.report_path(conn, :create_report, ReportType.meteorological()), params)
        |> json_response(200)

      assert_schema(json, "CreateReportResponse", api_spec)
    end

    test "create atypical report", %{conn_user: conn, api_spec: api_spec} do
      params = %{
        name: Faker.Lorem.sentence(3..4),
        longitude: Faker.Address.longitude(),
        latitude: Faker.Address.latitude(),
        comment: Faker.Lorem.paragraph()
      }

      json =
        conn
        |> post(Routes.report_path(conn, :create_report, ReportType.atypical_activity()), params)
        |> json_response(200)

      assert_schema(json, "CreateReportResponse", api_spec)
    end

    test "index reports", %{conn: conn, api_spec: api_spec} do
      insert!(:pollution_report)
      insert!(:jellyfish_report)
      insert!(:meteorological_report)
      insert!(:atypical_activity_report)

      json =
        conn
        |> get(Routes.report_path(conn, :index, "all"))
        |> json_response(200)

      assert_schema(json, "IndexReportResponse", api_spec)
    end
  end
end
