defmodule ISeeSea.Helpers.DateUtils do
  def date_display(date) do
    date
    |> extract_date()
    |> Calendar.strftime("%b %d, %Y")
  end

  def date_range_display(start_date, nil) when start_date in [nil, ""] do
    "MM/DD/YYYY - MM/DD/YYYY"
  end

  def date_range_display(start_date, end_date) when end_date in [nil, ""] do
    start_date_datetime = extract_date(start_date)
    Calendar.strftime(start_date_datetime, "%b %d, %Y")
  end

  def date_range_display(start_date, end_date) do
    start_date_datetime = extract_date(start_date)
    end_date_datetime = extract_date(end_date)

    {start_date_formatted, end_date_formatted} =
      case Date.compare(start_date_datetime, end_date_datetime) do
        :gt ->
          {
            Calendar.strftime(end_date_datetime, "%b %d, %Y"),
            Calendar.strftime(start_date_datetime, "%b %d, %Y")
          }

        _ ->
          {
            Calendar.strftime(start_date_datetime, "%b %d, %Y"),
            Calendar.strftime(end_date_datetime, "%b %d, %Y")
          }
      end

    "#{start_date_formatted} - #{end_date_formatted}"
  end

  defp extract_date(input) when input in [nil, ""], do: Date.utc_today()

  defp extract_date(datetime_string) when is_binary(datetime_string) do
    datetime_string
    |> String.split("T")
    |> List.first()
    |> Date.from_iso8601!()
  end

  defp extract_date(%DateTime{} = datetime), do: DateTime.to_date(datetime)
  defp extract_date(%NaiveDateTime{} = datetime), do: NaiveDateTime.to_date(datetime)
  defp extract_date(%{calendar: Calendar.ISO} = datetime), do: datetime
end
