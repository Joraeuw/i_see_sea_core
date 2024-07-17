defmodule AveratoWeb.Specs.Schemas.NotFoundErrorResponse do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "NotFoundErrorResponse",
    description: "Response returned when the resource could not be found",
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
