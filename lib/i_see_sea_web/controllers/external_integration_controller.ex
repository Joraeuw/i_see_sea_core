defmodule ISeeSeaWeb.ExternalIntegrationController do
  @moduledoc false

  use ISeeSeaWeb, :controller

  alias ISeeSea.DB.Models.BaseReport
  alias ISeeSea.ExternalIntegration.Parser

  def get_reports(conn, _params) do
    with {:ok, data} <-
           BaseReport.get_all_by(%{deleted: false}, [
             :jellyfish_report,
             pollution_report: :pollution_types
           ]),
         data <- Parser.parse(data) do
      success_binary(conn, data, "text/plain")
    else
      error ->
        error(conn, error)
    end
  end
end
