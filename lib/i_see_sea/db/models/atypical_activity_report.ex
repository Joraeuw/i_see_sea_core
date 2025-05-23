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
          %Lens{view: Lens.expanded(), translate: translate} = lens
        ) do
      atypical_activity_report
      |> Map.from_struct()
      |> Map.take([:report_id])
      |> Map.merge(%{
        storm_type: storm_type
      })
      |> ISeeSeaWeb.Trans.maybe_translate_entity(translate, "atypical_report")
      |> Map.merge(ISeeSeaWeb.Focus.view(base, lens))
    end

    def view(atypical_activity_report, %Lens{view: Lens.from_base(), translate: translate}) do
      atypical_activity_report
      |> Map.from_struct()
      |> Map.take([:report_id, :storm_type_id])
      |> ISeeSeaWeb.Trans.maybe_translate_entity(translate, "atypical_report")
    end
  end
end
