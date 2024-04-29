defmodule ISeeSeaWeb.ApiSpec.Schemas.MeteorologicalReportResponse do
  @moduledoc false

  require OpenApiSpex

  alias ISeeSea.Constants.SeaSwellType
  alias ISeeSea.Constants.WindType
  alias ISeeSea.Constants.FogType

  alias ISeeSeaWeb.ApiSpec.Schemas.BaseReportResponse
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "MeteorologicalReportResponse",
    type: :object,
    allOf: [
      BaseReportResponse,
      %Schema{
        type: :object,
        properties: %{
          report_id: %Schema{type: :integer, format: :id},
          fog_type: %Schema{type: :string, enum: FogType.values()},
          wind_type: %Schema{type: :string, enum: WindType.values()},
          sea_swell_type: %Schema{type: :string, enum: SeaSwellType.values()}
        }
      }
    ]
  })
end
