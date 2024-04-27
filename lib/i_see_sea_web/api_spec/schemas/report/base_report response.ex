defmodule ISeeSeaWeb.ApiSpec.Schemas.BaseReportResponse do
  @moduledoc false

  require OpenApiSpex

  alias ISeeSea.Constants.ReportType
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "BaseReportResponse",
    type: :object,
    properties: %{
      name: %Schema{type: :string},
      report_type: %Schema{type: :string, enum: ReportType.values()},
      report_date: %Schema{type: :string, format: :"date-time"},
      longitude: %Schema{type: :number},
      latitude: %Schema{type: :number},
      comment: %Schema{type: :string}
    }
  })
end
