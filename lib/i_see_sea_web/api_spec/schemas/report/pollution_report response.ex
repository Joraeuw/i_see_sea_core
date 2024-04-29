defmodule ISeeSeaWeb.ApiSpec.Schemas.PollutionReportResponse do
  @moduledoc false

  require OpenApiSpex

  alias ISeeSeaWeb.ApiSpec.Schemas.BaseReportResponse
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "PollutionReportResponse",
    type: :object,
    allOf: [
      BaseReportResponse,
      %Schema{
        type: :object,
        properties: %{
          report_id: %Schema{type: :integer, format: :id},
          pollution_types: %Schema{type: :array, items: %Schema{type: :string}}
        }
      }
    ]
  })
end
