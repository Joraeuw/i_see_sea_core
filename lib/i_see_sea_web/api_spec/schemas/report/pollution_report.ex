defmodule ISeeSeaWeb.ApiSpec.Schemas.PollutionReport do
  @moduledoc false

  require OpenApiSpex

  alias ISeeSeaWeb.ApiSpec.Schemas.BaseReport
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "PollutionReport",
    type: :object,
    allOf: [
      BaseReport,
      %Schema{
        type: :object,
        properties: %{
          pollution_types: %Schema{type: :array, items: %Schema{type: :string}}
        }
      }
    ]
  })
end
