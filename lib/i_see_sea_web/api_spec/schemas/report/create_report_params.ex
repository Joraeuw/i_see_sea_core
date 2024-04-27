defmodule ISeeSeaWeb.ApiSpec.Schemas.CreateReportParams do
  @moduledoc false

  require OpenApiSpex

  alias ISeeSeaWeb.ApiSpec.Schemas.PollutionReport
  alias ISeeSeaWeb.ApiSpec.Schemas.JellyfishReport

  OpenApiSpex.schema(%{
    title: "CreateReportParams",
    type: :object,
    oneOf: [
      JellyfishReport,
      PollutionReport
    ]
  })
end
