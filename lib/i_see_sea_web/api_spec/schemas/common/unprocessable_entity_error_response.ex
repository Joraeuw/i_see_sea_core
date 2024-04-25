defmodule ISeeSeaWeb.ApiSpec.Schemas.UnprocessableEntityErrorResponse do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "UnprocessableEntityErrorResponse",
    description: "Response returned when invalid parameters are provided",
    type: :object,
    properties: %{
      message: %Schema{
        type: :string,
        description: "Error message",
        default: "The requested action has failed."
      },
      reason: %Schema{
        type: :string,
        description: "Error reason"
      },
      errors: %Schema{
        type: :array,
        items: %Schema{
          type: :object,
          properties: %{
            property_name: %Schema{type: :string}
          }
        }
      }
    }
  })
end
