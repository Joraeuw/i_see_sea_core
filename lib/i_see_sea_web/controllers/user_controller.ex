defmodule ISeeSeaWeb.UserController do
  @moduledoc false

  use ISeeSeaWeb, :controller

  alias ISeeSea.Events.UserEmailVerification
  alias ISeeSea.DB.Models.BaseReport
  alias ISeeSeaWeb.Params.Filter

  @permission_scope "i_see_sea:users"
  plug(AssertPermissions, ["#{@permission_scope}:list_reports"] when action == :list_reports)
  plug(AssertPermissions, [] when action == :verify_email)

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
end
