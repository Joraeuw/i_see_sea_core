defmodule ISeeSeaWeb.ApiSpec.Schemas.CreateReportResponse do
  @moduledoc false

  require OpenApiSpex

  alias ISeeSeaWeb.ApiSpec.Schemas.MeteorologicalReportResponse
  alias ISeeSeaWeb.ApiSpec.Schemas.PollutionReportResponse
  alias ISeeSeaWeb.ApiSpec.Schemas.JellyfishReportResponse

  OpenApiSpex.schema(%{
    title: "CreateReportResponse",
    type: :object,
    anyOf: [
      JellyfishReportResponse,
      PollutionReportResponse,
      MeteorologicalReportResponse
    ]
  })
end
