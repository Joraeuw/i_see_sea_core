defmodule ISeeSeaWeb.ApiSpec.Operations.Report do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use OpenApiSpex.ControllerSpecs

      alias OpenApiSpex.Schema

      tags(["Report"])

    end
  end
end
