defmodule ISeeSeaWeb.ApiSpec.Operations.Page do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use OpenApiSpex.ControllerSpecs

      alias OpenApiSpex.Schema

      tags(["Page"])

      operation(:home,
        summary: "Show Page",
        responses: [
          ok: {"Response", "application/json", %Schema{}}
        ]
      )
    end
  end
end
