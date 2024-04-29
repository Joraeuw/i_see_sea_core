defmodule ISeeSeaWeb.ApiSpec.Schemas.AtypicalReportParams do
  @moduledoc false

  require OpenApiSpex

  alias ISeeSeaWeb.ApiSpec.Schemas.BaseReportParams

  OpenApiSpex.schema(%{
    title: "AtypicalReportParams",
    type: :object,
    allOf: [BaseReportParams],
    required: [:comment]
  })
end
