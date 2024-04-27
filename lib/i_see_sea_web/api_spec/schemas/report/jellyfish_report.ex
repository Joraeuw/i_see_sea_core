defmodule ISeeSeaWeb.ApiSpec.Schemas.JellyfishReport do
  @moduledoc false

  require OpenApiSpex

  alias ISeeSeaWeb.ApiSpec.Schemas.BaseReport
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "JellyfishReport",
    type: :object,
    allOf: [
      BaseReport,
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
