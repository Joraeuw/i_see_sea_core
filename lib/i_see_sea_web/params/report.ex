defmodule ISeeSeaWeb.Params.Report do
  @moduledoc false

  alias ISeeSea.Constants.SeaSwellType
  alias ISeeSea.Constants.WindType
  alias ISeeSea.Constants.FogType
  alias ISeeSea.Constants.ReportType

  use ISeeSeaWeb, :param

  defmacro __using__(_) do
    quote do
      use ISeeSeaWeb, :param

      defparams :create_base_report do
        required(:report_type, :string, values: ReportType.values())
        required(:name, :string)

        required(:longitude, :float,
          greater_than_or_equal_to: -180.0,
          less_than_or_equal_to: 180.0
        )

        required(:latitude, :float, greater_than_or_equal_to: -90.0, less_than_or_equal_to: 90.0)
        optional(:comment, :string)
      end
    end
  end

  defparams :create_jellyfish_report do
    required(:quantity, :integer, min: 1)
    optional(:species, :string)
  end

  defparams :create_pollution_report do
    required(:pollution_types, {:array, :string}, min: 1)
  end

  defparams :create_meteorological_report do
    required(:fog_type, :string, values: FogType.values())
    required(:wind_type, :string, values: WindType.values())
    required(:sea_swell_type, :string, values: SeaSwellType.values())
  end
end
