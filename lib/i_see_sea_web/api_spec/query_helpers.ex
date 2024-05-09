defmodule ISeeSeaWeb.ApiSpec.QueryHelpers do
  @moduledoc false

  alias OpenApiSpex.Schema

  def flop(filter_fields, order_fields, other \\ %{}) do
    [
      filters: [in: :query, schema: filters(filter_fields)],
      order_by: [in: :query, schema: order_by(order_fields)],
      order_direction: [in: :query, schema: order_direction()],
      page: [in: :query, schema: %Schema{type: :number, default: 1}],
      page_size: [in: :query, schema: %Schema{type: :number, default: 10}]
    ] ++
      other
  end

  def filters(fields) do
    %Schema{
      type: :array,
      items: %Schema{
        type: :object,
        properties: %{
          field: %Schema{
            type: :string,
            enum: fields
          },
          value: %Schema{type: :any},
          op: %Schema{type: :string, enum: Flop.Filter.allowed_operators(:all)}
        },
        required: [:field, :value]
      }
    }
  end

  def order_by(fields) do
    %Schema{
      type: :array,
      items: %Schema{type: :string, enum: fields}
    }
  end

  def order_direction do
    %Schema{
      type: :array,
      items: %Schema{type: :string, enum: ["asc", "desc"]}
    }
  end
end
