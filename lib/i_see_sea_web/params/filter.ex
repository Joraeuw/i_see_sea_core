defmodule ISeeSeaWeb.Params.Filter do
  @moduledoc false

  use ISeeSeaWeb, :param

  @default_filters [%{"field" => "deleted", "value" => false}]

  defparams :filter do
    optional(:filters, :string)
    optional(:order_by, {:array, :string})
    optional(:order_directions, {:array, :string})
  end

  defparams :pagination do
    optional(:page, :integer)
    optional(:page_size, :integer)
  end

  def parse(%{filters: filters_string} = filter) do
    parsed_filters =
      filters_string
      |> Jason.decode!()
      |> parse_data_ranges()
      |> ensure_defaults()

    Map.put(filter, :filters, parsed_filters)
  end

  def parse(no_filters), do: Map.put(no_filters, :filters, @default_filters)

  defp ensure_defaults(filters) do
    @default_filters
    |> Enum.reduce(filters, fn default_field, acc ->
      case Enum.find(acc, fn filter -> filter["field"] == default_field["field"] end) do
        nil -> [default_field | acc]
        _ -> acc
      end
    end)
  end

  defp parse_data_ranges(filters) do
    from_date_filter = Enum.find(filters, fn f -> f["field"] == "from_date" end)
    to_date_filter = Enum.find(filters, fn f -> f["field"] == "to_date" end)

    filters
    |> Enum.reject(fn f -> f["field"] in ["from_date", "to_date"] end)
    |> add_inserted_at_filters(from_date_filter, to_date_filter)
  end

  defp add_inserted_at_filters(filters, nil, nil), do: filters

  defp add_inserted_at_filters(filters, %{"value" => from_date}, nil) do
    inserted_at_filter = %{"field" => "inserted_at", "op" => ">=", "value" => from_date}
    [inserted_at_filter | filters]
  end

  defp add_inserted_at_filters(filters, nil, %{"value" => to_date}) do
    inserted_at_filter = %{"field" => "inserted_at", "op" => "<=", "value" => to_date}
    [inserted_at_filter | filters]
  end

  defp add_inserted_at_filters(filters, %{"value" => from_date}, %{"value" => to_date}) do
    from_inserted_at_filter = %{"field" => "inserted_at", "op" => ">=", "value" => from_date}
    to_inserted_at_filter = %{"field" => "inserted_at", "op" => "<=", "value" => to_date}
    [from_inserted_at_filter, to_inserted_at_filter | filters]
  end
end
