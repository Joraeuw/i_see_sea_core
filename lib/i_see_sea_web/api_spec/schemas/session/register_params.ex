defmodule ISeeSeaWeb.ApiSpec.Schemas.RegisterParams do
  @moduledoc false

  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "RegisterParams",
    type: :object,
    properties: %{
      first_name: %Schema{type: :string},
      last_name: %Schema{type: :string},
      email: %Schema{type: :string, format: :email},
      username: %Schema{type: :string},
      password: %Schema{type: :string},
      phone_number: %Schema{type: :string, required: false}
    },
    required: [:first_name, :last_name, :email, :username, :password]
  })
end
