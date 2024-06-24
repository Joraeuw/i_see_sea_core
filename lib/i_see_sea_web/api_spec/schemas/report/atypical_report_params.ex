defmodule ISeeSeaWeb.ApiSpec.Schemas.AtypicalReportParams do
  @moduledoc false

  require OpenApiSpex

  alias OpenApiSpex.Schema
  alias ISeeSea.Constants.StormType
  alias ISeeSeaWeb.ApiSpec.Schemas.BaseReportParams

  OpenApiSpex.schema(%{
    title: "AtypicalReportParams",
    type: :object,
    allOf: [
      BaseReportParams,
      %Schema{
        type: :object,
        properties: %{
          storm_type: %Schema{type: :string, enum: StormType.values()}
        }
      }
    ],
    required: [:comment, :storm_type]
  })
end
