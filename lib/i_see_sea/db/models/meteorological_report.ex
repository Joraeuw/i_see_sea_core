defmodule ISeeSea.DB.Models.MeteorologicalReport do
  @moduledoc false

  use ISeeSea.DB.DefaultModel,
    default_preloads: [:base_report, :fog_type, :wind_type, :sea_swell_type]

  alias ISeeSea.DB.Models.SeaSwellType
  alias ISeeSea.DB.Models.WindType
  alias ISeeSea.DB.Models.FogType
  alias ISeeSea.DB.Models.BaseReport

  @required_attrs [:report_id, :fog_type_id, :wind_type_id, :sea_swell_type_id]
  @allowed_attrs @required_attrs

  @primary_key false
  schema "meteorological_reports" do
    belongs_to(:fog_type, FogType, references: :name, type: :string)
    belongs_to(:wind_type, WindType, references: :name, type: :string)
    belongs_to(:sea_swell_type, SeaSwellType, references: :name, type: :string)

    belongs_to(:base_report, BaseReport, primary_key: :report_id, foreign_key: :report_id)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @allowed_attrs)
    |> validate_required(@required_attrs)
    |> foreign_key_constraint(:fog_type, name: :meteorological_reports_fog_type_id_fkey)
    |> foreign_key_constraint(:wind_type, name: :meteorological_reports_wind_type_id_fkey)
    |> foreign_key_constraint(:sea_swell_type,
      name: :meteorological_reports_sea_swell_type_id_fkey
    )
  end

  defimpl ISeeSeaWeb.Focus, for: __MODULE__ do
    require ISeeSeaWeb.Lens
    alias ISeeSeaWeb.Lens

    def view(
          %{
            base_report: base,
            fog_type_id: fog_type,
            wind_type_id: wind_type,
            sea_swell_type_id: sea_swell_type
          } = pollution_report,
          %Lens{view: Lens.expanded()} = lens
        ) do
      pollution_report
      |> Map.from_struct()
      |> Map.take([:report_id])
      |> Map.merge(ISeeSeaWeb.Focus.view(base, lens))
      |> Map.merge(%{
        fog_type: fog_type,
        wind_type: wind_type,
        sea_swell_type: sea_swell_type
      })
    end
  end
end
