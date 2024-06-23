defmodule ISeeSeaWeb.ApiSpec.Schemas.CreateReportParams do
  @moduledoc false

  require OpenApiSpex

  alias ISeeSeaWeb.ApiSpec.Schemas.AtypicalReportParams
  alias ISeeSeaWeb.ApiSpec.Schemas.MeteorologicalReportParams
  alias ISeeSeaWeb.ApiSpec.Schemas.OtherReportParams
  alias ISeeSeaWeb.ApiSpec.Schemas.PollutionReportParams
  alias ISeeSeaWeb.ApiSpec.Schemas.JellyfishReportParams

  OpenApiSpex.schema(%{
    title: "CreateReportParams",
    type: :object,
    oneOf: [
      JellyfishReportParams,
      PollutionReportParams,
      MeteorologicalReportParams,
      AtypicalReportParams,
      OtherReportParams
    ]
  })
end
