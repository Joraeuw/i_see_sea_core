defmodule ISeeSea.ExternalIntegration.Parser do
  require ISeeSea.Constants.ReportType, as: ReportType

  alias ISeeSea.DB.Models.BaseReport
  alias ISeeSea.DB.Models.PollutionReport
  alias ISeeSea.DB.Models.JellyfishReport

  def parse(data) do
    data
    |> Enum.map(&parse_report/1)
    |> Enum.reject(&is_nil/1)
  end

  defp parse_report(
         %BaseReport{
           report_type: ReportType.pollution(),
           pollution_report: %PollutionReport{pollution_types: pollution_types}
         } = base_report
       ) do
    if "oil" in Enum.map(pollution_types, fn type -> String.downcase(type.name) end) do
      "SPILL,#{base_report.latitude},#{base_report.longitude},2,O\r\n"
    else
      nil
    end
  end

  defp parse_report(
         %BaseReport{
           report_type: ReportType.jellyfish(),
           jellyfish_report: %JellyfishReport{quantity: quantity}
         } = base_report
       ) do
    "SPILL,#{base_report.latitude},#{base_report.longitude},#{quantity_to_meters(quantity)},J\r\n"
  end

  defp parse_report(_), do: nil

  defp quantity_to_meters(quantity) do
    case quantity do
      "1" -> 2
      "2 to 5" -> 4
      "6 to 10" -> 6
      "11 to 99" -> 8
      "100+" -> 10
    end
  end
end
