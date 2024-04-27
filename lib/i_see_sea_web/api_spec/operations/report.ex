defmodule ISeeSeaWeb.ApiSpec.Operations.Report do
  @moduledoc false

  alias ISeeSeaWeb.ApiSpec.Schemas.UnauthorizedErrorResponse
  alias ISeeSeaWeb.ApiSpec.Schemas.UnprocessableEntityErrorResponse
  alias ISeeSeaWeb.ApiSpec.Schemas.CreateReportResponse
  alias ISeeSeaWeb.ApiSpec.Schemas.CreateReportParams

  defmacro __using__(_) do
    quote do
      use OpenApiSpex.ControllerSpecs

      alias OpenApiSpex.Schema

      tags(["Report"])

      operation(:create_report,
        summary: "Create a report",
        security: [%{"BearerAuth" => []}],
        parameters: [
          id: [in: :path, description: "Report Type", type: :string]
        ],
        request_body: {"Create Report Params", "application/json", CreateReportParams},
        responses: [
          ok: {"Response", "application/json", CreateReportResponse},
          unprocessable_entity:
            {"Unprocessable Entity", "application/json", UnprocessableEntityErrorResponse},
          unauthorized: {"Unauthorized", "application/json", UnauthorizedErrorResponse}
        ]
      )
    end
  end
end
