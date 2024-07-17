defmodule ISeeSeaWeb.ApiSpec.Schemas.UnauthorizedErrorResponse do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "UnauthorizedErrorResponse",
    description: "Response returned when user is not authorized",
    type: :object,
    properties: %{
      message: %Schema{
        type: :string,
        description: "Error message",
        default: "The requested action has failed."
      },
      reason: %Schema{
        type: :string,
        description: "Error reason",
        default: "Authentication credentials were missing or incorrect."
      }
    }
  })
end
