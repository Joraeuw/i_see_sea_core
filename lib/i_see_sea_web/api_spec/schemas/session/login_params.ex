defmodule ISeeSeaWeb.ApiSpec.Schemas.LoginParams do
  @moduledoc false

  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "LoginParams",
    type: :object,
    properties: %{
      email: %Schema{type: :string, format: :email},
      password: %Schema{type: :string}
    },
    required: [:email, :password]
  })
end
