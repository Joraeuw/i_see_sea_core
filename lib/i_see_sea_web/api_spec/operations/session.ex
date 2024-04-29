defmodule ISeeSeaWeb.ApiSpec.Operations.Session do
  @moduledoc false

  alias ISeeSeaWeb.ApiSpec.Schemas.UnauthorizedErrorResponse
  alias ISeeSeaWeb.ApiSpec.Schemas.UnprocessableEntityErrorResponse

  alias ISeeSeaWeb.ApiSpec.Schemas.LoginParams
  alias ISeeSeaWeb.ApiSpec.Schemas.RegisterParams
  alias ISeeSeaWeb.ApiSpec.Schemas.SessionResponse

  defmacro __using__(_) do
    quote do
      use OpenApiSpex.ControllerSpecs

      alias OpenApiSpex.Schema

      tags(["Session"])

      operation(:register,
        summary: "Register a User",
        request_body: {"Register params", "application/json", RegisterParams},
        responses: [
          ok: {"Response", "application/json", SessionResponse},
          unprocessable_entity:
            {"Unprocessable Entity", "application/json", UnprocessableEntityErrorResponse}
        ]
      )

      operation(:login,
        summary: "Login",
        request_body: {"Register params", "application/json", LoginParams},
        responses: [
          ok: {"Response", "application/json", SessionResponse},
          unprocessable_entity:
            {"Unprocessable Entity", "application/json", UnprocessableEntityErrorResponse},
          unauthorized: {"Unauthorized", "application/json", UnauthorizedErrorResponse}
        ]
      )

      operation(:refresh,
        summary: "Refresh the JWT Token",
        security: [%{"BearerAuth" => ["Token"]}],
        responses: [
          ok: {"Response", "application/json", SessionResponse},
          unauthorized: {"Unauthorized", "application/json", UnauthorizedErrorResponse}
        ]
      )
    end
  end
end
