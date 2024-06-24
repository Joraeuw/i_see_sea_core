defmodule ISeeSeaWeb.ApiSpec.Schemas.AtypicalReportResponse do
  @moduledoc false

  require OpenApiSpex

  alias OpenApiSpex.Schema
  alias ISeeSea.Constants.StormType
  alias ISeeSeaWeb.ApiSpec.Schemas.BaseReportResponse

  OpenApiSpex.schema(%{
    title: "AtypicalReportResponse",
    type: :object,
    allOf: [
      BaseReportResponse,
      %Schema{
        type: :object,
        properties: %{
          storm_type: %Schema{type: :string, enum: StormType.values()}
        }
      }
    ]
  })
end
