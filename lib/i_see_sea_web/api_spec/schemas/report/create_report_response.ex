defmodule ISeeSeaWeb.ApiSpec.Schemas.CreateReportResponse do
  @moduledoc false

  require OpenApiSpex

  alias ISeeSeaWeb.ApiSpec.Schemas.AtypicalReportResponse
  alias ISeeSeaWeb.ApiSpec.Schemas.MeteorologicalReportResponse
  alias ISeeSeaWeb.ApiSpec.Schemas.OtherReportResponse
  alias ISeeSeaWeb.ApiSpec.Schemas.PollutionReportResponse
  alias ISeeSeaWeb.ApiSpec.Schemas.JellyfishReportResponse

  OpenApiSpex.schema(%{
    title: "CreateReportResponse",
    type: :object,
    anyOf: [
      JellyfishReportResponse,
      PollutionReportResponse,
      MeteorologicalReportResponse,
      AtypicalReportResponse,
      OtherReportResponse
    ]
  })
end
