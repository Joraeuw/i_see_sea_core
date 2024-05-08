defmodule ISeeSea.DB.Models.AtypicalActivityReport do
  @moduledoc false

  use ISeeSea.DB.DefaultModel, default_preloads: [:base_report]

  alias ISeeSea.DB.Models.BaseReport

  @attrs [:report_id]

  @primary_key false
  schema "atypical_activity_reports" do
    belongs_to(:base_report, BaseReport, primary_key: :report_id, foreign_key: :report_id)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
  end

  defimpl ISeeSeaWeb.Focus, for: __MODULE__ do
    require ISeeSeaWeb.Lens
    alias ISeeSeaWeb.Lens

    def view(%{base_report: base} = atypical_activity_report, %Lens{view: Lens.expanded()} = lens) do
      atypical_activity_report
      |> Map.from_struct()
      |> Map.take([:report_id])
      |> Map.merge(ISeeSeaWeb.Focus.view(base, lens))
    end

    def view(atypical_activity_report, %Lens{view: Lens.from_base()}) do
      atypical_activity_report
      |> Map.from_struct()
      |> Map.take([:report_id])
    end
  end
end
