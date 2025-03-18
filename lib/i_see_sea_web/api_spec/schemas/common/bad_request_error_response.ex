defmodule ISeeSeaWeb.ApiSpec.Schemas.Common.BadRequestErrorResponse do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "BadRequestErrorResponse",
    description: "Response returned when user sends unsupported format",
    type: :object,
    properties: %{
      message: %Schema{
        type: :string,
        description: "Error message",
        default: "The requested action has failed."
      },
      reason: %Schema{
        type: :string
      }
    }
  })
end
