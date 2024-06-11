defmodule ISeeSeaWeb.ReportControllerTest do
  use ISeeSeaWeb.ConnCase, async: true

  require ISeeSea.Constants.PictureTypes

  alias ISeeSea.Helpers.Environment

  alias ISeeSea.Constants.JellyfishQuantityRange
  alias ISeeSea.Constants.PictureTypes

  alias ISeeSea.DB.Models.Picture
  alias ISeeSea.DB.Models.PollutionReport
  alias ISeeSea.DB.Models.PollutionReportPollutionType
  alias ISeeSea.DB.Models.PollutionType
  alias ISeeSea.DB.Models.JellyfishReport

  alias ISeeSea.Constants.ReportType

  describe "create/2" do
    test "jellyfish report created successfully", %{conn_user: conn} do
      params = %{
        name: Faker.Lorem.sentence(3..4),
        longitude: Faker.Address.longitude(),
        latitude: Faker.Address.latitude(),
        quantity: JellyfishQuantityRange.from_11_to_99(),
        species: "dont_know",
        pictures: [
          %Plug.Upload{
            path: "./priv/example_images/sea_1.jpg",
            content_type: PictureTypes.jpg(),
            filename: "sea_1.jpg"
          }
        ]
      }

      response =
        conn
        |> post(Routes.report_path(conn, :create_report, ReportType.jellyfish()), params)
        |> json_response(200)

      {:ok, %{id: picture_id}} = Picture.get_by(%{report_id: Map.get(response, "report_id")})

      picture_url = Environment.backend_url() <> "/api/pictures/" <> Integer.to_string(picture_id)

      assert %{
               "report_id" => id,
               "latitude" => _,
               "longitude" => _,
               "name" => _,
               "quantity" => "11 to 99",
               "report_date" => _,
               "report_type" => "jellyfish",
               "species" => "dont_know",
               "pictures" => [^picture_url]
             } =
               response

      assert {:ok, %JellyfishReport{}} = JellyfishReport.get_by(%{report_id: id})
    end

    test "jellyfish report with a few images created successfully", %{conn_user: conn} do
      params = %{
        name: Faker.Lorem.sentence(3..4),
        longitude: Faker.Address.longitude(),
        latitude: Faker.Address.latitude(),
        quantity: JellyfishQuantityRange.from_1(),
        species: "other",
        pictures: [
          %Plug.Upload{
            path: "./priv/example_images/sea_1.jpg",
            content_type: PictureTypes.jpg(),
            filename: "sea_1.jpg"
          },
          %Plug.Upload{
            path: "./priv/example_images/sea_2.jpg",
            content_type: PictureTypes.jpg(),
            filename: "sea_2.jpg"
          }
        ]
      }

      response =
        conn
        |> post(Routes.report_path(conn, :create_report, ReportType.jellyfish()), params)
        |> json_response(200)

      {:ok, pictures} = Picture.get_all_by(%{report_id: Map.get(response, "report_id")})
      assert Enum.count(pictures) == 2

      assert %{
               "report_id" => id,
               "latitude" => _,
               "longitude" => _,
               "name" => _,
               "quantity" => "1",
               "report_date" => _,
               "report_type" => "jellyfish",
               "species" => "other",
               "pictures" => [_, _]
             } =
               response

      assert {:ok, %JellyfishReport{}} = JellyfishReport.get_by(%{report_id: id})
    end

    test "jellyfish report fails when no image is provided", %{conn_user: conn} do
      params = %{
        name: Faker.Lorem.sentence(3..4),
        longitude: Faker.Address.longitude(),
        latitude: Faker.Address.latitude(),
        quantity: JellyfishQuantityRange.from_2_to_5(),
        pictures: [],
        species: "dont_know"
      }

      response =
        conn
        |> post(Routes.report_path(conn, :create_report, ReportType.jellyfish()), params)
        |> json_response(422)

      assert response == %{
               "errors" => [%{"pictures" => "should have at least %{count} item(s)"}],
               "message" => "The requested action has failed.",
               "reason" => "Pictures should have at least %{count} item(s)."
             }
    end

    test "pollution report created successfully", %{conn_user: conn} do
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

    test "pollution report not created when invalid image type is provided", %{conn_user: conn} do
      params = %{
        name: Faker.Lorem.sentence(3..4),
        longitude: Faker.Address.longitude(),
        latitude: Faker.Address.latitude(),
        pollution_types: ["oil", "plastic"],
        pictures: [
          %Plug.Upload{
            path: "./priv/example_images/file.txt",
            content_type: "text/html; charset=utf-8",
            filename: "file.txt"
          }
        ]
      }

      response =
        conn
        |> post(Routes.report_path(conn, :create_report, ReportType.pollution()), params)
        |> json_response(400)

      assert response == %{
               "message" => "The requested action has failed.",
               "reason" =>
                 "At least one of your image types is unsupported! Supported image types are: jpg, png and webp."
             }
    end

    test "pollution type from another report is recognized", %{conn_user: conn, user: user} do
      p_type = insert!(:pollution_type, name: "other")

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
        pollution_types: ["other"],
        pictures: [
          %Plug.Upload{
            path: "./priv/example_images/sea_1.jpg",
            content_type: PictureTypes.jpg(),
            filename: "sea_1.jpg"
          }
        ]
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
               "pollution_types" => ["other"]
             } = response

      assert {:ok, %PollutionReport{}} = PollutionReport.get_by(%{report_id: id})
      assert 4 == PollutionType.all() |> elem(1) |> length()
      assert 2 == PollutionReportPollutionType.all() |> elem(1) |> length()
    end

    test "pollution type isn't recognized", %{conn_user: conn} do
      params = %{
        name: Faker.Lorem.sentence(3..4),
        longitude: Faker.Address.longitude(),
        latitude: Faker.Address.latitude(),
        pollution_types: ["invalid_1", "invalid_2"],
        pictures: [
          %Plug.Upload{
            path: "./priv/example_images/sea_1.jpg",
            content_type: PictureTypes.jpg(),
            filename: "sea_1.jpg"
          }
        ]
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

    test "meteorological report created successfully", %{conn_user: conn} do
      insert!(:wind_type, name: "strong")
      insert!(:fog_type, name: "thick")
      insert!(:sea_swell_type, name: "strong")

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

      response =
        conn
        |> post(Routes.report_path(conn, :create_report, ReportType.meteorological()), params)
        |> json_response(200)

      assert %{
               "report_type" => "meteorological",
               "fog_type" => "thick",
               "sea_swell_type" => "strong",
               "wind_type" => "strong",
               "comment" => "",
               "latitude" => _,
               "longitude" => _,
               "name" => _,
               "report_date" => _,
               "report_id" => _
             } = response
    end

    test "fog type isn't recognized", %{conn_user: conn} do
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

      response =
        conn
        |> post(Routes.report_path(conn, :create_report, ReportType.meteorological()), params)
        |> json_response(422)

      assert %{
               "errors" => [%{"fog_type" => "does not exist"}],
               "message" => "The requested action has failed.",
               "reason" => "Fog_type does not exist."
             } == response
    end

    test "wind type isn't recognized", %{conn_user: conn} do
      insert!(:fog_type, name: "thick")

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

      response =
        conn
        |> post(Routes.report_path(conn, :create_report, ReportType.meteorological()), params)
        |> json_response(422)

      assert %{
               "errors" => [%{"wind_type" => "does not exist"}],
               "message" => "The requested action has failed.",
               "reason" => "Wind_type does not exist."
             } == response
    end

    test "sea swell type isn't recognized", %{conn_user: conn} do
      insert!(:fog_type, name: "thick")
      insert!(:wind_type, name: "strong")

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

      response =
        conn
        |> post(Routes.report_path(conn, :create_report, ReportType.meteorological()), params)
        |> json_response(422)

      assert %{
               "errors" => [%{"sea_swell_type" => "does not exist"}],
               "message" => "The requested action has failed.",
               "reason" => "Sea_swell_type does not exist."
             } == response
    end

    test "atypical report created successfully", %{conn_user: conn} do
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

      response =
        conn
        |> post(Routes.report_path(conn, :create_report, ReportType.atypical_activity()), params)
        |> json_response(200)

      assert %{
               "report_type" => "atypical_activity",
               "comment" => _,
               "latitude" => _,
               "longitude" => _,
               "name" => _,
               "report_date" => _,
               "report_id" => _
             } = response
    end

    test "fail to create atypical report when no comment is provided", %{conn_user: conn} do
      params = %{
        name: Faker.Lorem.sentence(3..4),
        longitude: Faker.Address.longitude(),
        latitude: Faker.Address.latitude(),
        pictures: [
          %Plug.Upload{
            path: "./priv/example_images/sea_1.jpg",
            content_type: PictureTypes.jpg(),
            filename: "sea_1.jpg"
          }
        ]
      }

      response =
        conn
        |> post(Routes.report_path(conn, :create_report, ReportType.atypical_activity()), params)
        |> json_response(422)

      assert %{
               "errors" => [%{"comment" => "can't be blank"}],
               "message" => "The requested action has failed.",
               "reason" => "Comment can't be blank."
             } == response
    end

    test "fail to create report due to missing base report parameters", %{conn_user: conn} do
      params = %{
        name: Faker.Lorem.sentence(3..4),
        quantity: JellyfishQuantityRange.from_6_to_10(),
        species: "aurelia_aurita",
        pictures: [
          %Plug.Upload{
            path: "./priv/example_images/sea_1.jpg",
            content_type: PictureTypes.jpg(),
            filename: "sea_1.jpg"
          }
        ]
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
        latitude: Faker.Address.latitude(),
        species: "salp",
        pictures: [
          %Plug.Upload{
            path: "./priv/example_images/sea_1.jpg",
            content_type: PictureTypes.jpg(),
            filename: "sea_1.jpg"
          }
        ]
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
        order_direction: [:desc]
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
        fog_type: build(:fog_type, name: "thick"),
        wind_type: build(:wind_type, name: "strong"),
        sea_swell_type: build(:sea_swell_type, name: "strong")
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
        order_direction: [:desc]
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
        order_direction: [:desc]
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
