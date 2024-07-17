defmodule ISeeSeaWeb.ReportController do
  @moduledoc false

  use ISeeSeaWeb, :controller

  alias ISeeSea.DB.Models.User
  alias ISeeSea.Helpers.With
  alias ISeeSeaWeb.Params.Filter
  alias ISeeSea.DB.Models.BaseReport
  alias ISeeSea.DB.Logic.ReportOperations

  alias ISeeSea.Constants.ReportType

  @permission_scope "i_see_sea:reports"
  plug(AssertPermissions, ["#{@permission_scope}:create"] when action == :create_report)
  plug(AssertPermissions, [] when action in [:index, :delete_report])
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
         #! Issue with Goal Library. Report_type isn't handled and is always led to pass.
         #! The line bellow ensures correct behaviour
         :ok <- With.check(report_type in ["all" | ReportType.values()], :invalid_report_type),
         {:ok, filter_params} <- Filter.validate(:filter, params),
         {:ok, pagination_params} <- Filter.validate(:pagination, params),
         {:ok, entries, pagination} <-
           BaseReport.get_filtered_paginated_reports(
             report_type,
             Filter.parse(filter_params),
             pagination_params
           ) do
      success_paginated(conn, entries, pagination)
    else
      {:error, :invalid_report_type} ->
        error(
          conn,
          {:error,
           %Ecto.Changeset{
             errors: [
               report_type:
                 {"is invalid",
                  [
                    validation: :inclusion,
                    enum: ["all" | ReportType.values()]
                  ]}
             ]
           }}
        )

      error ->
        error(conn, error)
    end
  end

  def delete_report(%{assigns: %{user: user}} = conn, params) do
    with {:ok, %{report_id: report_id}} <- validate(:delete_report, params),
         {:ok, %{user_id: user_id} = report} <- BaseReport.get(report_id),
         :ok <- With.check(allow_action?(user, user_id), :forbidden),
         {:ok, _} <- BaseReport.soft_delete(report) do
      success_empty(conn)
    else
      {:error, :forbidden} ->
        error(conn, {:error, :forbidden})

      error ->
        error(conn, error)
    end
  end

  defp allow_action?(%User{role: %{name: "admin"}}, _), do: true
  defp allow_action?(%User{id: user_id}, user_id), do: true
  defp allow_action?(_, _), do: false
end
