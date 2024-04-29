defmodule ISeeSeaWeb.ApiSpec.Schemas.AtypicalReportResponse do
  @moduledoc false

  require OpenApiSpex

  alias ISeeSeaWeb.ApiSpec.Schemas.BaseReportResponse

  OpenApiSpex.schema(%{
    title: "AtypicalReportResponse",
    type: :object,
    allOf: [BaseReportResponse]
  })
end
