defmodule ISeeSeaWeb.ApiSpec.Schemas.UserInfo do
  @moduledoc false

  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "UserInfo",
    type: :object,
    properties: %{
      first_name: %Schema{type: :string},
      last_name: %Schema{type: :string},
      email: %Schema{type: :string, format: :email},
      username: %Schema{type: :string},
      phone_number: %Schema{type: :string, nullable: true},
      verified: %Schema{type: :boolean}
    }
  })
end
