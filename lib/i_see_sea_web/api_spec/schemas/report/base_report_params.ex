defmodule ISeeSeaWeb.ApiSpec.Schemas.BaseReportParams do
  @moduledoc false

  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "BaseReportParams",
    type: :object,
    properties: %{
      name: %Schema{type: :string},
      longitude: %Schema{type: :float},
      latitude: %Schema{type: :float},
      comment: %Schema{type: :string, required: false},
      pictures: %Schema{type: :array, items: %Schema{type: :binary}}
    },
    required: [:name, :longitude, :latitude, :pictures]
  })
end
