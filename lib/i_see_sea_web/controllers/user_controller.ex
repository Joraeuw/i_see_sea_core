defmodule ISeeSeaWeb.UserController do
  @moduledoc false

  use ISeeSeaWeb, :controller

  alias ISeeSea.Emails
  alias ISeeSea.Events.PasswordResetWorker
  alias ISeeSea.DB.Models.User
  alias ISeeSea.Events.UserEmailVerification
  alias ISeeSea.DB.Models.BaseReport
  alias ISeeSeaWeb.Params.Filter

  import ISeeSeaWeb.Trans

  @permission_scope "i_see_sea:users"
  plug(AssertPermissions, ["#{@permission_scope}:list_reports"] when action == :list_reports)

  plug(
    AssertPermissions,
    [] when action in [:verify_email, :user_info, :forgot_password, :reset_password]
  )

  plug(EnsurePermitted)

  def list_reports(%{assigns: %{user: user}} = conn, params) do
    with {:ok, %{report_type: report_type}} <- validate(:list_reports, params),
         {:ok, filter_params} <- Filter.validate(:filter, params),
         {:ok, pagination_params} <- Filter.validate(:pagination, params),
         {:ok, entries, pagination} <-
           BaseReport.get_user_filtered_paginated_reports(
             report_type,
             Filter.parse(filter_params),
             pagination_params,
             user.id
           ) do
      success_paginated(conn, entries, pagination)
    else
      error ->
        error(conn, error)
    end
  end

  def verify_email(conn, params) do
    with {:ok, %{token: token}} <- validate(:very_email, params),
         :ok <- UserEmailVerification.verify_email(token) do
      conn
      |> put_resp_content_type("text/html")
      |> send_resp(200, """
        <!DOCTYPE html>
        <html>
        <head>
          <title>Email Verification</title>
          <script type="text/javascript">
            setTimeout(function() {
              window.close();
            }, 3000); // Close the tab after 3 seconds
          </script>
        </head>
        <body>
          <p>Verification successful! This tab will close automatically in 3 seconds.</p>
        </body>
        </html>
      """)
    else
      error ->
        error(conn, error)
    end
  end

  def user_info(%{assigns: %{user: user}} = conn, _params) do
    success(conn, user)
  end

  def forgot_password(conn, params) do
    with {:ok, %{email: email}} <- validate(:forgot_password, params),
         {:ok, %{id: user_id} = user} <- User.get_by(%{email: email}),
         token <- UUID.uuid4(),
         {:ok, _} <- Emails.password_reset_email(user, token),
         {:ok, _} <- PasswordResetWorker.start_tracker(user_id, token) do
      success_empty(conn)
    else
      error -> error(conn, error)
    end
  end

  def reset_password(conn, params) do
    with {:ok, %{token: token, new_password: new_password}} <- validate(:reset_password, params),
         :ok <- PasswordResetWorker.reset_password(token, new_password) do
      success_binary(conn, translate(@locale, "u_c.password_reset"), "text")
    else
      error ->
        error(conn, error)
    end
  end
end
