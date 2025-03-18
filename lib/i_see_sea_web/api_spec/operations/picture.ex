defmodule ISeeSeaWeb.ApiSpec.Operations.Picture do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use OpenApiSpex.ControllerSpecs

      alias OpenApiSpex.Schema
      alias ISeeSeaWeb.ApiSpec.Schemas.Common.NotFoundErrorResponse

      tags(["Picture"])

      operation(:show,
        summary: "Show Picture",
        responses: [
          ok:
            {"Success", "image/webp OR image/jpeg OR image/png",
             %OpenApiSpex.Schema{type: :binary}},
          not_found: {"Not Found", "application/json", NotFoundErrorResponse}
        ]
      )
    end
  end
end
