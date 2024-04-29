defmodule ISeeSeaWeb.ApiSpec.Schemas.PollutionReportParams do
  @moduledoc false

  require OpenApiSpex

  alias ISeeSeaWeb.ApiSpec.Schemas.BaseReportParams
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "PollutionReportParams",
    type: :object,
    allOf: [
      BaseReportParams,
      %Schema{
        type: :object,
        properties: %{
          pollution_types: %Schema{type: :array, items: %Schema{type: :string}}
        }
      }
    ],
    required: [:pollution_types]
  })
end
