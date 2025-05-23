defmodule ISeeSeaWeb.ReportControllerTest do
  use ISeeSeaWeb.ConnCase, async: true

  require ISeeSea.Constants.PictureTypes

  alias ISeeSea.Helpers.Environment

  alias ISeeSea.Constants.JellyfishQuantityRange
  alias ISeeSea.Constants.PictureTypes
  alias ISeeSea.Constants.StormType

  alias ISeeSea.DB.Models.BaseReport
  alias ISeeSea.DB.Models.Picture
  alias ISeeSea.DB.Models.PollutionReport
  alias ISeeSea.DB.Models.PollutionReportPollutionType
  alias ISeeSea.DB.Models.PollutionType
  alias ISeeSea.DB.Models.JellyfishReport

  alias ISeeSea.Constants.ReportType

  describe "index/2" do
    test "successfully retrieve report data", %{conn: conn} do
      insert!(:pollution_report)
      insert!(:jellyfish_report)
      insert!(:meteorological_report)
      insert!(:atypical_activity_report)

      response =
        conn
        |> get(Routes.report_path(conn, :index, "all"))
        |> json_response(200)

      assert %{"pagination" => %{"page" => 1, "page_size" => 10, "total_count" => 4}} = response
    end

    test "fail to index unknown report type", %{conn: conn} do
      insert!(:pollution_report)
      insert!(:jellyfish_report)
      insert!(:meteorological_report)
      insert!(:atypical_activity_report)

      response =
        conn
        |> get(Routes.report_path(conn, :index, "invalid_report_type"))
        |> json_response(422)

      assert %{
               "errors" => [%{"report_type" => "is invalid"}],
               "message" => "The requested action has failed.",
               "reason" => "Report_type is invalid."
             } == response
    end

    test "successfully filter reports by date", %{conn: conn} do
      from_date = "2024-01-01T00:00:00Z"
      to_date = "2024-12-31T23:59:59Z"

      insert!(:pollution_report,
        base_report: build(:base_report, inserted_at: ~N[2024-01-10 12:00:00Z])
      )

      insert!(:jellyfish_report,
        base_report: build(:base_report, inserted_at: ~N[2024-02-15 12:00:00Z])
      )

      insert!(:meteorological_report,
        base_report: build(:base_report, inserted_at: ~N[2024-03-20 12:00:00Z])
      )

      # Outside range
      insert!(:atypical_activity_report,
        base_report: build(:base_report, inserted_at: ~N[2025-04-25 12:00:00Z])
      )

      # Outside range
      insert!(:pollution_report,
        base_report: build(:base_report, inserted_at: ~N[2023-12-31 12:00:00Z])
      )

      params = %{
        filters:
          Jason.encode!([
            %{field: :from_date, value: from_date},
            %{field: :to_date, value: to_date}
          ]),
        order_by: [:id],
        order_directions: [:desc]
      }

      response =
        conn
        |> get(Routes.report_path(conn, :index, "all", params))
        |> json_response(200)

      assert %{"pagination" => %{"page" => 1, "page_size" => 10, "total_count" => 3}} = response
    end

    test "successfully sort reports by date", %{conn: conn} do
      from_date = "2024-01-01T00:00:00Z"
      to_date = "2024-12-31T23:59:59Z"

      insert!(:pollution_report,
        base_report: build(:base_report, inserted_at: ~N[2024-01-10 12:00:00Z])
      )

      insert!(:jellyfish_report,
        base_report: build(:base_report, inserted_at: ~N[2024-02-15 12:00:00Z])
      )

      insert!(:meteorological_report,
        base_report: build(:base_report, inserted_at: ~N[2024-03-20 12:00:00Z])
      )

      # Outside range
      insert!(:atypical_activity_report,
        base_report: build(:base_report, inserted_at: ~N[2025-04-25 12:00:00Z])
      )

      # Outside range
      insert!(:pollution_report,
        base_report: build(:base_report, inserted_at: ~N[2023-12-31 12:00:00Z])
      )

      params = %{
        filters:
          Jason.encode!([
            %{field: :from_date, value: from_date},
            %{field: :to_date, value: to_date}
          ]),
        order_by: [:inserted_at],
        order_directions: [:asc]
      }

      response =
        conn
        |> get(Routes.report_path(conn, :index, "all", params))
        |> json_response(200)

      assert %{"pagination" => %{"page" => 1, "page_size" => 10, "total_count" => 3}} = response

      assert [
               %{"inserted_at" => "2024-01-10T12:00:00"},
               %{"inserted_at" => "2024-02-15T12:00:00"},
               %{"inserted_at" => "2024-03-20T12:00:00"}
             ] = response["entries"]

      params = %{
        filters:
          Jason.encode!([
            %{field: :from_date, value: from_date},
            %{field: :to_date, value: to_date}
          ]),
        order_by: [:inserted_at],
        order_directions: [:desc]
      }

      response =
        conn
        |> get(Routes.report_path(conn, :index, "all", params))
        |> json_response(200)

      assert %{"pagination" => %{"page" => 1, "page_size" => 10, "total_count" => 3}} = response

      assert [
               %{"inserted_at" => "2024-03-20T12:00:00"},
               %{"inserted_at" => "2024-02-15T12:00:00"},
               %{"inserted_at" => "2024-01-10T12:00:00"}
             ] = response["entries"]
    end

    test "returns no reports outside the date range", %{conn: conn} do
      from_date = "2025-01-01T00:00:00Z"
      to_date = "2025-12-31T23:59:59Z"

      insert!(:pollution_report,
        base_report: build(:base_report, inserted_at: ~N[2024-01-10 12:00:00Z])
      )

      insert!(:jellyfish_report,
        base_report: build(:base_report, inserted_at: ~N[2024-02-15 12:00:00Z])
      )

      params = %{
        filters:
          Jason.encode!([
            %{field: :from_date, value: from_date},
            %{field: :to_date, value: to_date}
          ]),
        order_by: [:id],
        order_directions: [:desc]
      }

      response =
        conn
        |> get(Routes.report_path(conn, :index, "all", params))
        |> json_response(200)

      assert %{"pagination" => %{"page" => 1, "page_size" => 10, "total_count" => 0}} = response
    end

    test "filters reports with overlapping date ranges", %{conn: conn} do
      from_date = "2024-01-01T00:00:00Z"
      to_date = "2024-03-31T23:59:59Z"

      insert!(:pollution_report,
        base_report: build(:base_report, inserted_at: ~N[2024-01-10 12:00:00Z])
      )

      insert!(:jellyfish_report,
        base_report: build(:base_report, inserted_at: ~N[2024-02-15 12:00:00Z])
      )

      # Outside range
      insert!(:meteorological_report,
        base_report: build(:base_report, inserted_at: ~N[2024-04-20 12:00:00Z])
      )

      insert!(:atypical_activity_report,
        base_report: build(:base_report, inserted_at: ~N[2024-03-25 12:00:00Z])
      )

      params = %{
        filters:
          Jason.encode!([
            %{field: :from_date, value: from_date},
            %{field: :to_date, value: to_date}
          ]),
        order_by: [:id],
        order_directions: [:desc]
      }

      response =
        conn
        |> get(Routes.report_path(conn, :index, "all", params))
        |> json_response(200)

      assert %{"pagination" => %{"page" => 1, "page_size" => 10, "total_count" => 3}} = response
    end

    test "successfully ignore deleted reports", %{conn: conn} do
      insert!(:pollution_report)
      insert!(:jellyfish_report)
      insert!(:meteorological_report)
      insert!(:atypical_activity_report)
      insert!(:pollution_report, base_report: build(:base_report, deleted: true))

      response =
        conn
        |> get(Routes.report_path(conn, :index, "all"))
        |> json_response(200)

      assert %{"pagination" => %{"page" => 1, "page_size" => 10, "total_count" => 4}} = response
    end

    test "successfully retrieve deleted reports", %{conn: conn} do
      insert!(:pollution_report)
      insert!(:jellyfish_report)
      insert!(:meteorological_report)
      insert!(:atypical_activity_report)
      insert!(:pollution_report, base_report: build(:base_report, deleted: true))

      params = %{
        filters:
          Jason.encode!([
            %{field: :deleted, value: true}
          ]),
        order_by: [:id],
        order_directions: [:desc]
      }

      response =
        conn
        |> get(Routes.report_path(conn, :index, "all"), params)
        |> json_response(200)

      assert %{"pagination" => %{"page" => 1, "page_size" => 10, "total_count" => 1}} = response
    end

    test "successfully retrieve jellyfish reports with filters", %{conn: conn} do
      insert!(:jellyfish_report)
      insert!(:jellyfish_report, species_id: "beroe_ovata")
      insert!(:jellyfish_report, species_id: "beroe_ovata")

      params = %{
        filters:
          Jason.encode!([
            %{field: :species, value: "beroe_ovata"}
          ]),
        order_by: [:id],
        order_directions: [:desc]
      }

      response =
        conn
        |> get(Routes.report_path(conn, :index, "jellyfish"), params)
        |> json_response(200)

      assert %{
               "entries" => [
                 %{
                   "comment" => _,
                   "latitude" => _,
                   "longitude" => _,
                   "name" => _,
                   "quantity" => "2 to 5",
                   "report_date" => _,
                   "report_id" => _,
                   "report_type" => "jellyfish",
                   "species" => "beroe_ovata"
                 },
                 %{
                   "comment" => _,
                   "latitude" => _,
                   "longitude" => _,
                   "name" => _,
                   "quantity" => "2 to 5",
                   "report_date" => _,
                   "report_id" => _,
                   "report_type" => "jellyfish",
                   "species" => "beroe_ovata"
                 }
               ],
               "pagination" => %{"page" => 1, "page_size" => 10, "total_count" => 2}
             } = response
    end

    test "successfully retrieve pollution reports with filters", %{conn: conn} do
      pollution_type = insert!(:pollution_type, name: "poly")

      insert!(:pollution_report)
      insert!(:jellyfish_report)
      pollution_report = insert!(:pollution_report)

      insert!(:pollution_report_pollution_type, %{
        pollution_report_id: pollution_report.report_id,
        pollution_type_id: pollution_type.name
      })

      params = %{
        filters:
          Jason.encode!([
            %{field: :pollution_types, value: ["poly"], op: :in}
          ])
      }

      response =
        conn
        |> get(Routes.report_path(conn, :index, "pollution"), params)
        |> json_response(200)

      assert %{
               "entries" => [
                 %{
                   "comment" => _,
                   "latitude" => _,
                   "longitude" => _,
                   "name" => _,
                   "report_date" => _,
                   "report_id" => _,
                   "report_type" => "pollution",
                   "pollution_types" => ["poly"]
                 }
               ],
               "pagination" => %{"page" => 1, "page_size" => 10, "total_count" => 1}
             } = response
    end

    test "successfully retrieve meteorological reports with filters", %{conn: conn} do
      insert!(:pollution_report)
      insert!(:jellyfish_report)
      insert!(:meteorological_report)

      insert!(:meteorological_report,
        fog_type_id: "thick",
        wind_type_id: "strong",
        sea_swell_type_id: "strong"
      )

      params = %{
        filters:
          Jason.encode!([
            %{field: :fog_type, value: ["thick", "no_fog"], op: :in},
            %{field: :wind_type, value: "strong", op: :==}
          ])
      }

      response =
        conn
        |> get(Routes.report_path(conn, :index, "meteorological"), params)
        |> json_response(200)

      assert %{
               "entries" => [
                 %{
                   "comment" => _,
                   "latitude" => _,
                   "longitude" => _,
                   "name" => _,
                   "report_date" => _,
                   "report_id" => _,
                   "fog_type" => "thick",
                   "wind_type" => "strong"
                 }
               ],
               "pagination" => %{"page" => 1, "page_size" => 10, "total_count" => 1}
             } = response
    end

    test "successfully retrieve atypical_activity reports with filters", %{conn: conn} do
      insert!(:pollution_report)
      insert!(:jellyfish_report)
      insert!(:meteorological_report)
      insert!(:atypical_activity_report)

      response =
        conn
        |> get(Routes.report_path(conn, :index, "atypical_activity"))
        |> json_response(200)

      assert %{
               "entries" => [
                 %{
                   "comment" => _,
                   "latitude" => _,
                   "longitude" => _,
                   "name" => _,
                   "report_date" => _,
                   "report_id" => _,
                   "report_type" => "atypical_activity"
                 }
               ],
               "pagination" => %{"page" => 1, "page_size" => 10, "total_count" => 1}
             } = response
    end

    test "fail when trying to filter by an unavailable parameter", %{conn: conn} do
      insert!(:jellyfish_report)
      insert!(:jellyfish_report, species_id: "cassiopea_andromeda")
      insert!(:jellyfish_report, species_id: "cassiopea_andromeda")

      params = %{
        filters:
          Jason.encode!([
            %{field: :random_parameter, value: "cassiopea_andromeda"}
          ]),
        order_by: [:id],
        order_directions: [:desc]
      }

      response =
        conn
        |> get(Routes.report_path(conn, :index, "jellyfish"), params)
        |> json_response(400)

      assert %{
               "message" => "The requested action has failed.",
               "reason" => "Malformed request syntax."
             } == response
    end

    test "fail when trying to filter by a parameter of another report", %{conn: conn} do
      insert!(:jellyfish_report)
      insert!(:jellyfish_report, species_id: "chrysaora_pseudoocellata")
      insert!(:jellyfish_report, species_id: "chrysaora_pseudoocellata")

      params = %{
        filters:
          Jason.encode!([
            %{field: :fog_type, value: "thick"}
          ]),
        order_by: [:id],
        order_directions: [:desc]
      }

      response =
        conn
        |> get(Routes.report_path(conn, :index, "jellyfish"), params)
        |> json_response(400)

      assert %{
               "message" => "The requested action has failed.",
               "reason" => "Malformed request syntax."
             } == response
    end
  end
end
