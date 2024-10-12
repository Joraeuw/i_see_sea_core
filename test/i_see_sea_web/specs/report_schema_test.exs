defmodule ISeeSeaWeb.Specs.ReportSchemaTest do
  @moduledoc false
  use ISeeSeaWeb.ConnCase, async: true

  import OpenApiSpex.TestAssertions

  alias ISeeSea.Constants.JellyfishQuantityRange
  alias ISeeSea.Constants.ReportType
  alias ISeeSea.Constants.StormType

  describe "report schema" do
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
