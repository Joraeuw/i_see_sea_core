defmodule ISeeSeaWeb.ApiSpec do
  @moduledoc false

  alias OpenApiSpex.{Components, Info, OpenApi, Paths, SecurityScheme, Server}
  alias ISeeSeaWeb.{Endpoint, Router}

  @behaviour OpenApi

  @impl OpenApi
  def spec do
    %OpenApi{
      servers: [
        Server.from_endpoint(Endpoint)
      ],
      info: %Info{
        title: "I See Sea",
        version: "1.0"
      },
      paths: Paths.from_router(Router),
      components: %Components{
        securitySchemes: %{"BearerAuth" => %SecurityScheme{type: "https", scheme: "bearer"}}
      }
    }
    |> OpenApiSpex.resolve_schema_modules()
  end
end
