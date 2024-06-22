defmodule ISeeSeaWeb.ApiSpec.Operations.Report do
  @moduledoc false

  alias ISeeSea.Constants.ReportType

  alias AveratoWeb.Specs.Schemas.BadRequestErrorResponse
  alias AveratoWeb.Specs.Schemas.NotFoundErrorResponse
  alias AveratoWeb.Specs.Schemas.ForbiddenErrorResponse

  alias ISeeSeaWeb.ApiSpec.QueryHelpers

  alias ISeeSeaWeb.ApiSpec.Schemas.IndexReportResponse
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
        summary: "Create Report",
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
        summary: "List Reports",
        description: "Lists all reports. Filters are applicable.",
        parameters:
          QueryHelpers.flop(
            [
              "name",
              "quantity",
              "species",
              "pollution_types",
              "fog_type",
              "wind_type",
              "sea_swell_type",
              "inserted_at",
              "from_date",
              "to_date"
            ],
            [
              "id",
              "name",
              "report_date",
              "quantity",
              "species",
              "fog_type",
              "wind_type",
              "sea_swell_type",
              "inserted_at"
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

      operation(:delete_report,
        summary: "Delete Report",
        security: [%{"BearerAuth" => ["Token"]}],
        parameters: [
          report_id: [
            in: :path,
            description: "Report id",
            schema: %Schema{type: :string}
          ]
        ],
        responses: [
          ok: {"Response", "application/json", %Schema{}},
          unauthorized: {"Unauthorized", "application/json", UnauthorizedErrorResponse},
          forbidden: {"Forbidden", "application/json", ForbiddenErrorResponse},
          not_found: {"Not Found", "application/json", NotFoundErrorResponse}
        ]
      )
    end
  end
end
