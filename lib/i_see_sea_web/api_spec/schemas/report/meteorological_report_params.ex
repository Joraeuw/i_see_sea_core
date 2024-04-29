defmodule ISeeSeaWeb.ApiSpec.Schemas.MeteorologicalReportParams do
  @moduledoc false

  require OpenApiSpex

  alias ISeeSea.Constants.SeaSwellType
  alias ISeeSea.Constants.WindType
  alias ISeeSea.Constants.FogType

  alias ISeeSeaWeb.ApiSpec.Schemas.BaseReportParams
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "MeteorologicalReportParams",
    type: :object,
    allOf: [
      BaseReportParams,
      %Schema{
        type: :object,
        properties: %{
          fog_type: %Schema{type: :string, enum: FogType.values()},
          wind_type: %Schema{type: :string, enum: WindType.values()},
          sea_swell_type: %Schema{type: :string, enum: SeaSwellType.values()}
        }
      }
    ]
  })
end
