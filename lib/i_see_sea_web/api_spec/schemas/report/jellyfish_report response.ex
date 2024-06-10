defmodule ISeeSeaWeb.ApiSpec.Schemas.JellyfishReportResponse do
  @moduledoc false

  require OpenApiSpex

  alias ISeeSeaWeb.ApiSpec.Schemas.BaseReportResponse
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "JellyfishReportResponse",
    type: :object,
    allOf: [
      BaseReportResponse,
      %Schema{
        type: :object,
        properties: %{
          report_id: %Schema{type: :integer, format: :id},
          quantity: %Schema{type: :string},
          species: %Schema{type: :string}
        }
      }
    ]
  })
end
