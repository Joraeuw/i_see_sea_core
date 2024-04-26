defmodule ISeeSeaWeb.ReportController do
  @moduledoc false

  use ISeeSeaWeb, :controller

  alias ISeeSea.DB.Logic.ReportOperations

  def create_report(%{assigns: %{user: user}} = conn, params) do
    with {:ok, validated_base} <- validate(:create_base_report, params),
         {:ok, report} <- ReportOperations.create(user, validated_base, params) do
      success(conn, report)
    else
      error -> error(conn, error)
    end
  end
end
