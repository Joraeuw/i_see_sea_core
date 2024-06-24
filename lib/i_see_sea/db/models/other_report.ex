defmodule ISeeSea.DB.Models.OtherReport do
  @moduledoc false

  use ISeeSea.DB.DefaultModel, default_preloads: [base_report: [:pictures, :user]]

  alias ISeeSea.DB.Models.BaseReport

  @attrs [:report_id]

  @primary_key false
  schema "other_reports" do
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

    def view(%{base_report: base} = other_report, %Lens{view: Lens.expanded()} = lens) do
      other_report
      |> Map.from_struct()
      |> Map.take([:report_id])
      |> Map.merge(ISeeSeaWeb.Focus.view(base, lens))
    end

    def view(other_report, %Lens{view: Lens.from_base()}) do
      other_report
      |> Map.from_struct()
      |> Map.take([:report_id])
    end
  end
end
