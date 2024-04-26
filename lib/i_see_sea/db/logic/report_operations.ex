defmodule ISeeSea.DB.Logic.ReportOperations do
  @moduledoc false

  alias ISeeSea.DB.Models.PollutionReportPollutionType
  alias ISeeSea.Helpers.With
  alias ISeeSea.DB.Models.PollutionType
  alias ISeeSea.DB.Models.PollutionReport
  alias ISeeSea.DB.Models.JellyfishReport
  alias ISeeSea.DB.Models.BaseReport
  alias ISeeSea.Repo
  alias ISeeSeaWeb.Params.Report

  def create(user, validated_base, params) do
    Repo.transaction(fn ->
      with {:ok, %BaseReport{id: id, report_type: report_type}} <-
             BaseReport.create(
               Map.merge(validated_base, %{user_id: user.id, report_date: DateTime.utc_now()})
             ),
           {:ok, report} <- create_specific_report(id, report_type, params) do
        report
      else
        {:error, error} -> Repo.rollback(error)
      end
    end)
  end

  defp create_specific_report(base_report_id, report_type, params)
       when report_type == "jellyfish" do
    with {:ok, validated_prams} <- Report.validate(:create_jellyfish_report, params),
         {:ok, jellyfish_report} <-
           JellyfishReport.create(Map.merge(validated_prams, %{report_id: base_report_id})) do
      {:ok, jellyfish_report}
    else
      {:error, error} -> Repo.rollback(error)
    end
  end

  # defp create_specific_report(report_type, params) when report_type == "meteorological" do

  # end

  # defp create_specific_report(report_type, params) when report_type == "atypical" do

  # end

  defp create_specific_report(base_report_id, report_type, params)
       when report_type == "pollution" do
    with {:ok, %{pollution_types: pollution_types}} <-
           Report.validate(:create_pollution_report, params),
         {:ok, pollution_report} <- PollutionReport.create(%{report_id: base_report_id}),
         :ok <-
           With.check(
             attach_pollution_type(base_report_id, pollution_types),
             :pollution_type_not_attached
           ) do
      {:ok, pollution_report |> Repo.reload!() |> Repo.preload([:base_report, :pollution_types])}
    else
      {:error, error} -> Repo.rollback(error)
    end
  end

  defp attach_pollution_type(report_id, pollution_types) do
    Enum.all?(pollution_types, fn pollution_type_name ->
      with {:ok, %{id: pt_id}} <- PollutionType.create(pollution_type_name),
           {:ok, _} <-
             PollutionReportPollutionType.create(%{
               pollution_type_id: pt_id,
               pollution_report_id: report_id
             }) do
        true
      else
        _ -> false
      end
    end)
  end
end
