defmodule ISeeSeaWeb.SessionControllerTest do
  use ISeeSeaWeb.ConnCase, async: true

  describe "register/2" do
    test "successfully create a user", %{conn: conn} do
      params = %{
        first_name: "Sam",
        last_name: "Blue",
        email: "email@gmail.com",
        password: "A123456",
        username: "Dobby"
      }

      assert %{"token" => _} =
               conn
               |> post(Routes.session_path(conn, :register), params)
               |> json_response(200)
    end

    test "fail to create a user due to invalid params", %{conn: conn} do
      params = %{
        email: "email@gmail.com",
        password: "A123456"
      }

      response =
        conn
        |> post(Routes.session_path(conn, :register), params)
        |> json_response(422)

      assert response == %{
               "message" => "The requested action has failed.",
               "errors" => [
                 %{"last_name" => "can't be blank"},
                 %{"first_name" => "can't be blank"},
                 %{"username" => "can't be blank"}
               ],
               "reason" =>
                 "last_name can't be blank, first_name can't be blank, username can't be blank."
             }
    end
  end

  describe "login/2" do
    test "successfully login user", %{conn: conn, user: %{email: email}} do
      params = %{
        email: email,
        password: "A123456"
      }

      assert %{"token" => _} =
               conn
               |> post(Routes.session_path(conn, :login), params)
               |> json_response(200)
    end

    test "fail to login user due to incorrect credentials", %{conn: conn} do
      params = %{
        email: "not_valid_email@abv.bg",
        password: "A123456"
      }

      response =
        conn
        |> post(Routes.session_path(conn, :login), params)
        |> json_response(401)

      assert %{
               "message" => "The requested action has failed.",
               "reason" => "Email or password is incorrect."
             } == response
    end

    test "fail to login user when fields are missing", %{conn: conn, user: %{email: email}} do
      params = %{
        email: email
      }

      response =
        conn
        |> post(Routes.session_path(conn, :login), params)
        |> json_response(422)

      assert %{
               "message" => "The requested action has failed.",
               "errors" => [%{"password" => "can't be blank"}],
               "reason" => "password can't be blank."
             } == response
    end
  end

  describe "refresh/2" do
    test "successfully refresh token", %{conn_user: conn} do
      assert %{"token" => _} =
               conn
               |> get(Routes.session_path(conn, :refresh))
               |> json_response(200)
    end

    test "fail when no token is provided", %{conn: conn} do
      assert %{
               "message" => "The requested action has failed.",
               "reason" => "Authentication credentials were missing or incorrect."
             } ==
               conn
               |> get(Routes.session_path(conn, :refresh))
               |> json_response(401)
    end

    test "fail when invalid token is provided", %{conn: conn} do
      conn = Plug.Conn.put_req_header(conn, "authorization", "bearer: " <> "invalid_token")

      assert %{
               "message" => "The requested action has failed.",
               "reason" => "Authentication credentials were missing or incorrect."
             } ==
               conn
               |> get(Routes.session_path(conn, :refresh))
               |> json_response(401)
    end
  end
end
