defmodule ISeeSeaWeb.Specs.SessionSchemaTest do
  @moduledoc false
  use ISeeSeaWeb.ConnCase, async: true
  import OpenApiSpex.TestAssertions

  describe "session schema" do
    test "login", %{conn_user: conn, api_spec: api_spec, user: user} do
      params = %{
        "email" => user.email,
        "password" => "A123456"
      }

      json =
        conn
        |> post(Routes.session_path(conn, :login), params)
        |> json_response(200)

      assert_schema(json, "SessionResponse", api_spec)
    end

    test "register", %{conn: conn, api_spec: api_spec} do
      params = %{
        first_name: "Joe",
        last_name: "Smith",
        username: "joe_smith",
        email: "joe_smith@gmail.com",
        password: "A123456"
      }

      json =
        conn
        |> post(Routes.session_path(conn, :register), params)
        |> json_response(200)

      assert_schema(json, "SessionResponse", api_spec)
    end

    test "refresh", %{conn_user: conn, api_spec: api_spec} do
      json =
        conn
        |> get(Routes.session_path(conn, :refresh))
        |> json_response(200)

      assert_schema(json, "SessionResponse", api_spec)
    end
  end
end
