defmodule ISeeSeaWeb.ApiSpec.Schemas.SessionResponse do
  @moduledoc false

  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "SessionResponse",
    type: :object,
    properties: %{
      token: %Schema{type: :string, description: "JWT Token"}
    }
  })
end
