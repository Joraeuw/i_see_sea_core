defmodule ISeeSeaWeb.ApiSpec.Schemas.JellyfishReportParams do
  @moduledoc false

  require OpenApiSpex

  alias ISeeSeaWeb.ApiSpec.Schemas.BaseReportParams
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "JellyfishReportParams",
    type: :object,
    allOf: [
      BaseReportParams,
      %Schema{
        type: :object,
        properties: %{
          quantity: %Schema{type: :integer},
          species: %Schema{type: :string, required: false}
        }
      }
    ]
  })
end
