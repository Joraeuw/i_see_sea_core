defmodule ISeeSeaWeb.ReportController do
  @moduledoc false

  use ISeeSeaWeb, :controller
  use ISeeSeaWeb.ApiSpec.Operations.Report

  alias ISeeSea.Helpers.With
  alias ISeeSeaWeb.Params.Filter
  alias ISeeSea.DB.Models.BaseReport

  alias ISeeSea.Constants.ReportType

  def index(conn, params) do
    with {:ok, %{report_type: report_type}} <- Params.Report.validate(:index, params),
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
      Logger.info(
        "Reports with ids: #{inspect(Enum.map(entries, & &1.id))} were retrieved with filters: #{inspect(Filter.parse(filter_params))} and pagination: #{inspect(pagination_params)}"
      )

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
end
