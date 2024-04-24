defmodule AveratoWeb.Specs.Schemas.ForbiddenErrorResponse do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "ForbiddenErrorResponse",
    description: "Response returned when user has no access rights",
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
        default: "No access rights to fullfil the requested action."
      }
    }
  })
end
