defmodule ISeeSeaWeb.ApiSpec.Schemas.SessionResponse do
  @moduledoc false

  require OpenApiSpex

  alias ISeeSeaWeb.ApiSpec.Schemas.UserInfo
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "SessionResponse",
    type: :object,
    properties: %{
      token: %Schema{type: :string, description: "JWT Token"},
      user: UserInfo
    }
  })
end
