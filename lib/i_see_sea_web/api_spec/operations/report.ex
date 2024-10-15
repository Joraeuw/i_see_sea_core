defmodule ISeeSeaWeb.ApiSpec.Operations.Report do
  @moduledoc false

  alias ISeeSea.Constants.ReportType

  alias AveratoWeb.Specs.Schemas.BadRequestErrorResponse

  alias ISeeSeaWeb.ApiSpec.QueryHelpers

  alias ISeeSeaWeb.ApiSpec.Schemas.IndexReportResponse
  alias ISeeSeaWeb.ApiSpec.Schemas.UnprocessableEntityErrorResponse

  defmacro __using__(_) do
    quote do
      use OpenApiSpex.ControllerSpecs
      require ISeeSeaWeb.ApiSpec.QueryHelpers, as: QueryHelpers

      alias OpenApiSpex.Schema

      tags(["Report"])

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
              "storm_type",
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
    end
  end
end
