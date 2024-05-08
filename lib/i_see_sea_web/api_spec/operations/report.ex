defmodule ISeeSeaWeb.ApiSpec.Operations.Report do
  @moduledoc false

  alias ISeeSeaWeb.ApiSpec.Schemas.IndexReportResponse
  alias AveratoWeb.Specs.Schemas.BadRequestErrorResponse
  alias ISeeSea.Constants.ReportType
  alias ISeeSeaWeb.ApiSpec.QueryHelpers
  alias ISeeSeaWeb.ApiSpec.Schemas.UnauthorizedErrorResponse
  alias ISeeSeaWeb.ApiSpec.Schemas.UnprocessableEntityErrorResponse
  alias ISeeSeaWeb.ApiSpec.Schemas.CreateReportResponse
  alias ISeeSeaWeb.ApiSpec.Schemas.CreateReportParams

  defmacro __using__(_) do
    quote do
      use OpenApiSpex.ControllerSpecs
      require ISeeSeaWeb.ApiSpec.QueryHelpers, as: QueryHelpers

      alias OpenApiSpex.Schema

      tags(["Report"])

      operation(:create_report,
        summary: "Create a report",
        security: [%{"BearerAuth" => ["Token"]}],
        parameters: [
          report_type: [
            in: :path,
            description: "Report Type",
            schema: %Schema{type: :string, enum: ReportType.values()}
          ]
        ],
        request_body: {"Create Report Params", "application/json", CreateReportParams},
        responses: [
          ok: {"Response", "application/json", CreateReportResponse},
          unprocessable_entity:
            {"Unprocessable Entity", "application/json", UnprocessableEntityErrorResponse},
          unauthorized: {"Unauthorized", "application/json", UnauthorizedErrorResponse}
        ]
      )

      operation(:index,
        summary: "List reports",
        parameters:
          QueryHelpers.flop(
            [
              "name",
              "quantity",
              "species",
              "pollution_types",
              "fog_type",
              "wind_type",
              "sea_swell_type"
            ],
            [
              "id",
              "name",
              "report_date",
              "quantity",
              "species",
              "fog_type",
              "wind_type",
              "sea_swell_type"
            ],
            report_type: [
              in: :path,
              description: "Report Type",
              schema: %Schema{type: :string, enum: ["all" | ReportType.values()]}
            ]
          ),
        responses: [
          ok: {"Response", "application/json", IndexReportResponse},
          bad_request: {"Bad Request", "application/json", BadRequestErrorResponse},
          unprocessable_entity:
            {"Unprocessable Entity", "application/json", UnprocessableEntityErrorResponse}
        ]
      )
    end
  end
end
