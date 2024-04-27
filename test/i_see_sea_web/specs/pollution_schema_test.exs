defmodule ISeeSeaWeb.Specs.PollutionSchemaTest do
  @moduledoc false
  alias ISeeSea.Constants.ReportType
  use ISeeSeaWeb.ConnCase, async: true
  import OpenApiSpex.TestAssertions

  describe "pollution schema" do
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
  end
end
