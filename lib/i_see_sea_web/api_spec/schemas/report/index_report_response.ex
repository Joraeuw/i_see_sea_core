defmodule ISeeSeaWeb.ApiSpec.Schemas.IndexReportResponse do
  @moduledoc false

  require OpenApiSpex

  alias ISeeSeaWeb.ApiSpec.Pagination
  alias ISeeSeaWeb.ApiSpec.Schemas.BaseReportResponse
  alias ISeeSeaWeb.ApiSpec.Schemas.AtypicalReportResponse
  alias ISeeSeaWeb.ApiSpec.Schemas.MeteorologicalReportResponse
  alias ISeeSeaWeb.ApiSpec.Schemas.PollutionReportResponse
  alias ISeeSeaWeb.ApiSpec.Schemas.JellyfishReportResponse

  OpenApiSpex.schema(
    Pagination.apply("IndexReportResponse", [
      JellyfishReportResponse,
      PollutionReportResponse,
      MeteorologicalReportResponse,
      AtypicalReportResponse,
      BaseReportResponse
    ])
  )
end
