defmodule ISeeSeaWeb.ApiSpec.Schemas.OtherReportParams do
  @moduledoc false

  require OpenApiSpex

  alias ISeeSeaWeb.ApiSpec.Schemas.BaseReportParams

  OpenApiSpex.schema(%{
    title: "OtherReportParams",
    type: :object,
    allOf: [
      BaseReportParams
    ],
    required: [:comment]
  })
end
