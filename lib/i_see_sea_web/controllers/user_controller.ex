defmodule ISeeSeaWeb.UserController do
  @moduledoc false

  use ISeeSeaWeb, :controller

  alias ISeeSea.DB.Models.BaseReport
  alias ISeeSeaWeb.Params.Filter

  def list_reports(%{assigns: %{user: user}} = conn, params) do
    with {:ok, %{report_type: report_type}} <- validate(:list_reports, params),
         {:ok, filter_params} <- Filter.validate(:filter, params),
         {:ok, pagination_params} <- Filter.validate(:pagination, params),
         {:ok, entries, pagination} <-
           BaseReport.get_user_filtered_paginated_reports(
             report_type,
             filter_params,
             pagination_params,
             user.id
           ) do
      success_paginated(conn, entries, pagination)
    else
      error ->
        error(conn, error)
    end
  end
end
