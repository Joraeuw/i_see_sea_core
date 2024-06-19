defmodule ISeeSeaWeb.Params.Filter do
  @moduledoc false

  use ISeeSeaWeb, :param

  @default_filters [%{"field" => "deleted", "value" => false}]

  defparams :filter do
    optional(:filters, :string)
    optional(:order_by, {:array, :string})
    optional(:order_direction, {:array, :string})
  end

  defparams :pagination do
    optional(:page, :integer)
    optional(:page_size, :integer)
  end

  def parse(%{filters: filters_string} = filter) do
    parsed_filters =
      filters_string
      |> Jason.decode!()
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
end
