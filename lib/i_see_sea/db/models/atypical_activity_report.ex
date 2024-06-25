defmodule ISeeSea.DB.Models.AtypicalActivityReport do
  @moduledoc false

  use ISeeSea.DB.DefaultModel, default_preloads: [:storm_type, base_report: [:pictures, :user]]

  alias ISeeSea.DB.Models.BaseReport
  alias ISeeSea.DB.Models.StormType

  @attrs [:report_id, :storm_type_id]

  @primary_key false
  schema "atypical_activity_reports" do
    belongs_to(:base_report, BaseReport, primary_key: :report_id, foreign_key: :report_id)

    belongs_to(:storm_type, StormType, references: :name, type: :string)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
    |> foreign_key_constraint(:fog_type_id, name: :meteorological_reports_fog_type_id_fkey)
  end

  defimpl ISeeSeaWeb.Focus, for: __MODULE__ do
    require ISeeSeaWeb.Lens
    alias ISeeSeaWeb.Lens

    def view(
          %{base_report: base, storm_type_id: storm_type} = atypical_activity_report,
          %Lens{view: Lens.expanded()} = lens
        ) do
      atypical_activity_report
      |> Map.from_struct()
      |> Map.take([:report_id])
      |> Map.merge(ISeeSeaWeb.Focus.view(base, lens))
      |> Map.merge(%{
        storm_type: storm_type
      })
    end

    def view(atypical_activity_report, %Lens{view: Lens.from_base()}) do
      atypical_activity_report
      |> Map.from_struct()
      |> Map.take([:report_id, :storm_type_id])
    end
  end
end
