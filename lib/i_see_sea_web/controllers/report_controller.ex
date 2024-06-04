defmodule ISeeSeaWeb.ReportController do
  @moduledoc false

  use ISeeSeaWeb, :controller

  alias ISeeSeaWeb.Params.Filter
  alias ISeeSea.DB.Models.BaseReport
  alias ISeeSea.DB.Logic.ReportOperations

  @permission_scope "i_see_sea:reports"
  plug(AssertPermissions, ["#{@permission_scope}:create"] when action == :create_report)
  plug(AssertPermissions, [] when action == :index)
  plug(EnsurePermitted)

  def create_report(%{assigns: %{user: user}} = conn, params) do
    with {:ok, validated_base} <- validate(:create_base_report, params),
         {:ok, report} <- ReportOperations.create(user, validated_base, params) do
      success(conn, report)
    else
      {:error, :failed_to_attach_pollution_type} ->
        error(conn, {:error, :unprocessable_entity})

      {:error, :image_not_uploaded} ->
        error(
          conn,
          {:error, :bad_request,
           "At least one of your image types is unsupported! Supported image types are: jpg, png and webp."}
        )

      error ->
        error(conn, error)
    end
  end

  def index(conn, params) do
    with {:ok, %{report_type: report_type}} <- validate(:index, params),
         {:ok, filter_params} <- Filter.validate(:filter, params),
         {:ok, pagination_params} <- Filter.validate(:pagination, params),
         {:ok, entries, pagination} <-
           BaseReport.get_filtered_paginated_reports(
             report_type,
             filter_params,
             pagination_params
           ) do
      success_paginated(conn, entries, pagination)
    else
      error ->
        error(conn, error)
    end
  end
end
