defmodule ISeeSeaWeb.UserControllerTest do
  @moduledoc false
  use ISeeSeaWeb.ConnCase, async: true
  use Oban.Testing, repo: ISeeSea.Repo

  alias ISeeSea.DB.Models.Role
  alias ISeeSea.DB.Models.User
  alias ISeeSea.Events.PasswordResetWorker
  alias ISeeSea.Events.UserEmailVerification

  describe "list_reports/2" do
    test "successfully retrieve report data", %{conn_user: conn, user: user} do
      insert!(:pollution_report)
      insert!(:jellyfish_report)
      insert!(:atypical_activity_report)

      insert!(:pollution_report, base_report: build(:base_report, user: user))
      insert!(:jellyfish_report, base_report: build(:base_report, user: user))
      insert!(:meteorological_report, base_report: build(:base_report, user: user))
      insert!(:atypical_activity_report, base_report: build(:base_report, user: user))

      response =
        conn
        |> get(Routes.user_path(conn, :list_reports, "all"))
        |> json_response(200)

      assert %{"pagination" => %{"page" => 1, "page_size" => 10, "total_count" => 4}} = response
    end

    test "fail to retrieve report data when unauthenticated", %{conn: conn} do
      response =
        conn
        |> get(Routes.user_path(conn, :list_reports, "all"))
        |> json_response(401)

      assert %{
               "message" => "The requested action has failed.",
               "reason" => "Authentication credentials were missing or incorrect."
             } == response
    end
  end

  describe "verify_email/2" do
    test "successfully verify user email", %{conn: conn} do
      %{id: user_id, verified: false} = insert!(:user, verified: false)
      token = UUID.uuid4()
      UserEmailVerification.start_tracker(user_id, token)

      conn
      |> get(Routes.user_path(conn, :verify_email, token))
      |> response(200)

      assert {:ok, %{verified: true}} = User.get(user_id)
      assert {:error, :not_found} = UserEmailVerification.get_scheduled(token)
    end

    test "fail to verify user email when token is invalid", %{conn: conn} do
      %{id: user_id} = insert!(:user, verified: false)
      token = UUID.uuid4()
      UserEmailVerification.start_tracker(user_id, token)

      response =
        conn
        |> get(Routes.user_path(conn, :verify_email, "invalid_token"))
        |> json_response(404)

      assert %{
               "message" => "The requested action has failed.",
               "reason" => "The resource could not be found."
             } == response

      assert {:ok, %{verified: false}} = User.get(user_id)
    end
  end

  describe "forgot_password/2" do
    test "successfully send password reset email", %{conn: conn} do
      %{id: user_id, email: email} = insert!(:user)

      conn =
        conn
        |> post(Routes.user_path(conn, :forgot_password), %{"email" => email})

      assert response(conn, 204)

      assert_received {:email,
                       %Swoosh.Email{
                         to: [{_, ^email}],
                         subject: "Инструкции за нулиране на парола / Reset Password Instructions"
                       }}

      assert_enqueued(worker: PasswordResetWorker, args: %{user_id: user_id})
    end

    test "fail to send password reset email when email is not found", %{conn: conn} do
      response =
        conn
        |> post(Routes.user_path(conn, :forgot_password), %{"email" => "nonexistent@example.com"})
        |> json_response(404)

      assert %{
               "message" => "The requested action has failed.",
               "reason" => "Entity not found!"
             } == response
    end

    test "fail to send password reset email when params are invalid", %{conn: conn} do
      response =
        conn
        |> post(Routes.user_path(conn, :forgot_password), %{"invalid_param" => "value"})
        |> json_response(422)

      assert %{
               "message" => "The requested action has failed.",
               "reason" => "Email can't be blank.",
               "errors" => [%{"email" => "can't be blank"}]
             } ==
               response
    end
  end

  describe "reset_password/2" do
    test "successfully reset password", %{conn: conn} do
      %{id: user_id} = insert!(:user)
      token = UUID.uuid4()
      new_password = "new_password123"

      PasswordResetWorker.start_tracker(user_id, token)
      assert {:ok, %{"user_id" => _, "token" => _}} = PasswordResetWorker.get_scheduled(token)

      conn =
        conn
        |> post(Routes.user_path(conn, :reset_password, token), %{
          "new_password" => new_password
        })

      assert response(conn, 200)

      {:ok, %{password: hashed_new_password}} = User.get(user_id)

      assert Bcrypt.verify_pass(new_password, hashed_new_password)
    end

    test "successfully reset password when admin", %{conn: conn} do
      {:ok, %Role{id: role_id}} = Role.get_by(%{name: "admin"})

      %{id: user_id} = insert!(:user, role_id: role_id)

      token = UUID.uuid4()
      new_password = "new_password123"

      PasswordResetWorker.start_tracker(user_id, token)
      assert {:ok, %{"user_id" => _, "token" => _}} = PasswordResetWorker.get_scheduled(token)

      conn =
        conn
        |> post(Routes.user_path(conn, :reset_password, token), %{
          "new_password" => new_password
        })

      assert response(conn, 200)

      {:ok, %{password: hashed_new_password, role_id: ^role_id}} = User.get(user_id)

      assert Bcrypt.verify_pass(new_password, hashed_new_password)
    end

    test "fail to reset password when token is invalid", %{conn: conn} do
      new_password = "new_password123"

      response =
        conn
        |> post(Routes.user_path(conn, :reset_password, "invalid_token"), %{
          "new_password" => new_password
        })
        |> json_response(404)

      assert %{
               "message" => "The requested action has failed.",
               "reason" => "The resource could not be found."
             } ==
               response

      assert {:error, :not_found} = PasswordResetWorker.get_scheduled("invalid_token")
    end

    test "fail to reset password when params are invalid", %{conn: conn} do
      response =
        conn
        |> post(Routes.user_path(conn, :reset_password, "token"), %{"invalid_param" => "value"})
        |> json_response(422)

      assert %{
               "message" => "The requested action has failed.",
               "reason" => "New_password can't be blank.",
               "errors" => [%{"new_password" => "can't be blank"}]
             } ==
               response
    end
  end
end
