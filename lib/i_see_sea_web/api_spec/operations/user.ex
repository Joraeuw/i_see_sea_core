defmodule ISeeSeaWeb.ApiSpec.Operations.User do
  @moduledoc false

  alias ISeeSeaWeb.ApiSpec.Schemas.IndexReportResponse
  alias AveratoWeb.Specs.Schemas.BadRequestErrorResponse
  alias ISeeSea.Constants.ReportType
  alias ISeeSeaWeb.ApiSpec.QueryHelpers
  alias ISeeSeaWeb.ApiSpec.Schemas.UnauthorizedErrorResponse
  alias ISeeSeaWeb.ApiSpec.Schemas.UnprocessableEntityErrorResponse

  defmacro __using__(_) do
    quote do
      use OpenApiSpex.ControllerSpecs
      require ISeeSeaWeb.ApiSpec.QueryHelpers, as: QueryHelpers

      alias OpenApiSpex.Schema

      tags(["Users"])

      operation(:list_reports,
        summary: "List User Reports",
        description: "Lists user related reports. Can apply filters",
        security: [%{"BearerAuth" => ["Token"]}],
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
            {"Unprocessable Entity", "application/json", UnprocessableEntityErrorResponse},
          unauthorized: {"Unauthorized", "application/json", UnauthorizedErrorResponse}
        ]
      )

      operation(:verify_email, false)
    end
  end
end
