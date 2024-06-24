defmodule ISeeSeaWeb.ApiSpec.Schemas.OtherReportResponse do
  @moduledoc false

  require OpenApiSpex

  alias ISeeSeaWeb.ApiSpec.Schemas.BaseReportResponse

  OpenApiSpex.schema(%{
    title: "OtherReportResponse",
    type: :object,
    allOf: [BaseReportResponse]
  })
end
