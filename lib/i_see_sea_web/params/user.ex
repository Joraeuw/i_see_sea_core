defmodule ISeeSeaWeb.Params.User do
  @moduledoc false

  alias ISeeSea.Constants.ReportType

  defmacro __using__(_) do
    quote do
      use ISeeSeaWeb, :param

      defparams :list_reports do
        required(:report_type, :string, values: ["all" | ReportType.values()])
      end

      defparams :very_email do
        required(:token, :string)
      end
    end
  end
end
