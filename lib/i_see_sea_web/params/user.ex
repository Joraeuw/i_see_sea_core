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

      defparams :forgot_password do
        required(:email, :string)
      end

      defparams :reset_password do
        required(:token, :string)
        required(:new_password, :string, format: :password)
      end
    end
  end
end
