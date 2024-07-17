defmodule ISeeSeaWeb.ApiSpec.Pagination do
  @moduledoc false

  alias OpenApiSpex.Schema

  def apply(title, schemas) do
    %Schema{
      title: title,
      type: :object,
      properties: %{
        entries: %Schema{type: :array, items: %Schema{type: :object, anyOf: schemas}},
        pagination: %Schema{
          type: :object,
          properties: %{
            page: %Schema{type: :number},
            page_size: %Schema{type: :number},
            total_count: %Schema{type: :number}
          }
        }
      }
    }
  end
end
