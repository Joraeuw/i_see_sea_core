defmodule ISeeSeaWeb.Specs.ReportSchemaTest do
  @moduledoc false
  use ISeeSeaWeb.ConnCase, async: true

  import OpenApiSpex.TestAssertions

  require ISeeSea.Constants.PictureTypes

  alias ISeeSea.Constants.JellyfishQuantityRange
  alias ISeeSea.Constants.PictureTypes
  alias ISeeSea.Constants.ReportType
  alias ISeeSea.Constants.StormType

  describe "report schema" do
    test "create jellyfish report", %{conn_user: conn, api_spec: api_spec} do
      params = %{
        name: Faker.Lorem.sentence(3..4),
        longitude: Faker.Address.longitude(),
        latitude: Faker.Address.latitude(),
        quantity: JellyfishQuantityRange."from_100+"(),
        species: "dont_know",
        pictures: [
          %Plug.Upload{
            path: "./priv/example_images/sea_1.jpg",
            content_type: PictureTypes.jpg(),
            filename: "sea_1.jpg"
          }
        ]
      }

      json =
        conn
        |> post(Routes.report_path(conn, :create_report, ReportType.jellyfish()), params)
        |> json_response(200)

      assert_schema(json, "CreateReportResponse", api_spec)
    end

    test "create pollution report", %{conn_user: conn, api_spec: api_spec} do
      params = %{
        name: Faker.Lorem.sentence(3..4),
        longitude: Faker.Address.longitude(),
        latitude: Faker.Address.latitude(),
        pollution_types: ["oil", "plastic"],
        pictures: [
          %Plug.Upload{
            path: "./priv/example_images/sea_1.jpg",
            content_type: PictureTypes.jpg(),
            filename: "sea_1.jpg"
          }
        ]
      }

      json =
        conn
        |> post(Routes.report_path(conn, :create_report, ReportType.pollution()), params)
        |> json_response(200)

      assert_schema(json, "CreateReportResponse", api_spec)
    end

    test "create meteorological report", %{conn_user: conn, api_spec: api_spec} do
      params = %{
        name: Faker.Lorem.sentence(3..4),
        longitude: Faker.Address.longitude(),
        latitude: Faker.Address.latitude(),
        fog_type: "thick",
        wind_type: "strong",
        sea_swell_type: "strong",
        pictures: [
          %Plug.Upload{
            path: "./priv/example_images/sea_1.jpg",
            content_type: PictureTypes.jpg(),
            filename: "sea_1.jpg"
          }
        ]
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
        comment: Faker.Lorem.paragraph(),
        storm_type: StormType.hailstorm(),
        pictures: [
          %Plug.Upload{
            path: "./priv/example_images/sea_1.jpg",
            content_type: PictureTypes.jpg(),
            filename: "sea_1.jpg"
          }
        ]
      }

      json =
        conn
        |> post(Routes.report_path(conn, :create_report, ReportType.atypical_activity()), params)
        |> json_response(200)

      assert_schema(json, "CreateReportResponse", api_spec)
    end

    test "create other report", %{conn_user: conn, api_spec: api_spec} do
      params = %{
        name: Faker.Lorem.sentence(3..4),
        longitude: Faker.Address.longitude(),
        latitude: Faker.Address.latitude(),
        comment: Faker.Lorem.paragraph(),
        pictures: [
          %Plug.Upload{
            path: "./priv/example_images/sea_1.jpg",
            content_type: PictureTypes.jpg(),
            filename: "sea_1.jpg"
          }
        ]
      }

      json =
        conn
        |> post(Routes.report_path(conn, :create_report, ReportType.other()), params)
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
