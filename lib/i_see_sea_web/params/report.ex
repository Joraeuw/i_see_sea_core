defmodule ISeeSeaWeb.Params.Report do
  @moduledoc false

  alias ISeeSea.Constants.ReportType

  use ISeeSeaWeb, :param

  defmacro __using__(_) do
    quote do
      use ISeeSeaWeb, :param

      defparams :create_base_report do
        required(:report_type, :string, values: ReportType.values())
        required(:name, :string)
        required(:pictures, {:array, :map}, min: 1)

        required(:longitude, :float,
          greater_than_or_equal_to: -180.0,
          less_than_or_equal_to: 180.0
        )

        required(:latitude, :float, greater_than_or_equal_to: -90.0, less_than_or_equal_to: 90.0)
        optional(:comment, :string)
      end

      defparams :index do
        required(:report_type, :string, values: ["all" | ReportType.values()])
      end
    end
  end

  defparams :create_jellyfish_report do
    required(:quantity, :integer, min: 1)
    required(:species, :string, values: ISeeSea.DB.Models.JellyfishSpecies.values())
  end

  defparams :create_pollution_report do
    required(:pollution_types, {:array, :string}, min: 1)
  end

  defparams :create_meteorological_report do
    required(:fog_type, :string, values: ISeeSea.Constants.FogType.values())
    required(:wind_type, :string, values: ISeeSea.Constants.WindType.values())
    required(:sea_swell_type, :string, values: ISeeSea.Constants.SeaSwellType.values())
  end

  defparams :create_atypical_activity_report do
    required(:comment, :string)
  end
end
