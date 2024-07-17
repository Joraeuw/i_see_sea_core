defmodule ISeeSeaWeb.ApiSpec.Schemas.JellyfishReportParams do
  @moduledoc false

  require OpenApiSpex

  alias ISeeSeaWeb.ApiSpec.Schemas.BaseReportParams
  alias OpenApiSpex.Schema

  alias ISeeSea.Constants.JellyfishQuantityRange

  OpenApiSpex.schema(%{
    title: "JellyfishReportParams",
    type: :object,
    allOf: [
      BaseReportParams,
      %Schema{
        type: :object,
        properties: %{
          quantity: %Schema{type: :string, enum: JellyfishQuantityRange.values()},
          species: %Schema{type: :string}
        }
      }
    ],
    required: [:quantity, :species]
  })
end
